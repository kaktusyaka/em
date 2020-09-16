class TrialOrder < ApplicationRecord
  include AASM

  URL = 'https://top4smm.com/api.php'

  belongs_to :user

  validates :user, presence: true
  validates :link_url, presence: true, http_url: true
  validate :service_correct_url, on: :create

  before_create :send_new_order
  after_create :update_trial, :init_check_status

  aasm do
    state :pending, initial: true
    state :processing
    state :in_progress
    state :completed
    state :partially_completed
    state :canceled
    state :error

    event :to_processing do
      transitions from: :pending, to: :processing
    end

    event :to_in_progress do
      transitions from: %i[pending processing], to: :in_progress
    end

    event :to_completed do
      transitions from: %i[pending processing in_progress], to: :completed
    end

    event :to_partially_completed do
      transitions from: %i[pending processing in_progress],
                  to: :partially_completed
    end

    event :to_canceled do
      transitions from: %i[pending processing in_progress], to: :canceled
      after do
        user.update_columns(trial_claimed: false)
      end
    end

    event :to_error do
      transitions from: %i[pending processing in_progress], to: :error
      after do
        user.update_columns(trial_claimed: false)
      end
    end
  end

  private

  def init_check_status
    delay_for(60.seconds, retry: false).check_status(external_id)
  end

  def send_new_order
    @query = {}
    @query[:query] = { key: Rails.application.credentials.dig(:piar_for_you_token),
                       act: 'new_order',
                       service_id: 187,
                       link: link_url,
                       count: 50 }

    extra_params

    response = HTTParty.get(URL, @query)

    response = JSON.parse(response.parsed_response)

    if response.key?('error')
      errors.add(:base, response['error']['error_message'])
      throw :abort
    else
      self.external_id = response['res']['order_id']

      Setting.find_by(var: 'balance').update value: response['res']['balance']
    end
  end

  def check_status(_param_id = nil)
    return if completed? || partially_completed? || canceled? || error?

    @query = {}
    @query[:query] = { key: Rails.application.credentials.dig(:piar_for_you_token),
                       act: 'order_info',
                       id: external_id }

    response = HTTParty.get(URL, @query)
    response = JSON.parse(response.parsed_response)

    return if response.key?('error')

    if aasm_state != response['status'].parameterize.underscore
      send("to_#{response['status'].parameterize.underscore}!")
    end

    delay_for(5.minutes, retry: false).check_status(external_id)
  end

  def update_trial
    user.update_columns(trial_claimed: true)
  end

  def service_correct_url
    return if link_url.match(link_url_regexp)

    errors.add(:link_url, 'does not much pattern. URL should be like this https://instagram.com/p/aye83DjauH')
  end

  def link_url_regexp
    %r{(https?://(?:www\.)?instagram\.com/p/([^/?#&]+)).*}ix
  end
end
