class Instagram::Promotion < ApplicationRecord
  include AASM
  include InstagramUnfollowModule
  include InstagramFollowModule

  FOLLOW_LIMIT_PER_HOUR = (3..5).freeze

  belongs_to :account
  has_many :users, dependent: :destroy

  has_one_attached :profile_picture

  validates :target, presence: true, length: { maximum: 255 }, uniqueness: { scope: :account_id }

  with_options allow_blank: true, numericality: { greater_than: -1 } do
    validates :max_followers
    validates :max_following
    validates :min_posts
  end

  with_options length: { maximum: 65_536 } do
    validates :stop_words
    validates :white_words
  end

  before_validation :check_target, on: :create

  aasm column: 'status' do
    state :created, initial: true
    state :waiting
    state :in_progress
    state :paused
    state :unfollowing
    state :finished
    state :errored

    event :wait do
      transitions from: :created, to: :waiting
    end

    event :to_in_progress do
      transitions from: %i[paused waiting created unfollowing], to: :in_progress

      after do
        delay.following(id)
      end
    end

    event :pause do
      transitions from: %i[in_progress waiting created unfollowing], to: :paused
    end

    event :finish do
      transitions from: %i[created in_progress paused waiting unfollowing], to: :finished

      after do
        next_record.try(:to_in_progress)
      end
    end

    event :to_unfollow do
      transitions from: :in_progress, to: :unfollowing

      after do
        delay_for(20.minutes).unfollow
      end
    end

    event :error do
      transitions from: %i[created in_progress paused waiting unfollowing], to: :errored

      after do
        next_record.try(:to_in_progress)
      end
    end
  end

  after_create :set_status

  def following(_id = nil)
    return unless in_progress?

    opts = {}
    opts.merge!(max_id: end_cursor) if end_cursor.present?

    result = api.user_followers(pk_id, rank_token, opts)
    user_ids = result['users'].map { |u| u['pk'] }
    friendships = api.friendships_show_many(user_ids)

    delay.processing(id, result['users'], friendships, result['next_max_id'])

    finish! unless result['next_max_id']
  end

  def unfollow
    if keep_personal_following?
      unfollow_without_personal
    else
      unfollow_all
    end
  end

  def api
    @api ||= InstagramService::Client.new(account)
  end

  private

  def next_record
    account.promotions.waiting.where("id > ?", id).first
  end

  def check_target
    res = ProxyHttp.get("https://instagram.com/#{target}?__a=1")
    if res.parsed_response['graphql']['user']['is_private']
      errors.add(:target, 'is private. You can use only public accounts')
    else
      self.pk_id = res.parsed_response['graphql']['user']['id']
      self.total_followers = res.parsed_response['graphql']['user']['edge_followed_by']['count']
      self.rank_token = api.send(:generate_uuid)
      file = open(res.parsed_response['graphql']['user']['profile_pic_url'])
      self.profile_picture = { io: file, filename: "#{SecureRandom.hex}.jpg" }
    end
  end

  def set_status
    if account.promotions.in_progress.none?
      to_in_progress!
    else
      wait!
    end
  end
end
