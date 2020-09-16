class Instagram::Account < ApplicationRecord
  extend FriendlyId
  friendly_id :username

  belongs_to :user, class_name: '::User'

  has_one_attached :profile_picture

  has_many :promotions, dependent: :destroy
  has_many :statistics, as: :statisticable, dependent: :destroy
  has_many :users, through: :promotions, dependent: :destroy #used_accounts

  attr_encrypted :password, key: Rails.application.credentials.dig(:instagram, :password_key)

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true

  serialize :account_session, Hash
  serialize :client_settings, Hash

  after_create -> { delay.pull_id(id) }

  private

  def pull_id(_id = nil)
    api = InstagramService::Client.new(self)
    response = api.current_user

    update_columns pk_id: response['user']['pk'], biography: response['user']['biography'], full_name: response['user']['full_name']

    file = open(response['user']['profile_pic_url'])
    profile_picture.attach(io: file, filename: "#{SecureRandom.hex}.jpg")

    delay_for(rand(2..10).seconds).pull_numbers(id)
  end

  def pull_numbers(_id = nil)
    api = InstagramService::Client.new(self)
    response = api.user_detail_info(pk_id)

    statistics.create!(follower:  response['user_detail']['user']['follower_count'], follow: response['user_detail']['user']['following_count'])

    delay_for(24.hours).pull_numbers(id)
  end
end
