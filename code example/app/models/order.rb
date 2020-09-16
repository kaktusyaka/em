# frozen_string_literal: true

class Order < ApplicationRecord
  include AASM

  URL = 'https://top4smm.com/api.php'

  belongs_to :user
  belongs_to :service
  has_one :payment_history

  has_unique_field :identifier, length: 10, type: :human

  validates :service, presence: true
  validates :user, presence: true
  validates :link_url, presence: true, http_url: true
  validates :quantity, presence: true, numericality: { only_integer: true }
  validates :comments, length: { maximum: 65_536 }

  validate :service_correct_url, on: :create
  validate :check_quantity, on: :create
  validate :check_balance, on: :create

  before_create :send_new_order

  after_create :record_payment_history, :init_check_status

  aasm do
    state :pending, initial: true
    state :processing
    state :in_progress
    state :completed
    state :partially_completed
    state :canceled
    state :error

    event :to_pending do
      transitions from: :pending, to: :pending
    end

    event :to_processing do
      transitions from: :pending, to: :processing
    end

    event :to_in_progress do
      transitions from: %i[pending processing], to: :in_progress
    end

    event :to_completed do
      transitions from: %i[pending processing in_progress], to: :completed

      after do
        if user.allow_email_on_complete_order?
          UserMailer.delay.order_completed(self)
        end
      end
    end

    event :to_partially_completed do
      transitions from: %i[pending processing in_progress],
                  to: :partially_completed
    end

    event :to_canceled do
      transitions from: %i[pending processing in_progress], to: :canceled
      after do
        user.update_columns(balance: payment_history.amount.abs + user.balance)
        payment_history.destroy
      end
    end

    event :to_error do
      transitions from: %i[pending processing in_progress], to: :error
    end
  end

  private

  def service_correct_url
    return if link_url_regexp.blank?
    return if link_url.match(link_url_regexp)

    errors.add(:link_url, 'does not much pattern. URL should be like this https://instagram.com/p/aye83DjauH')
  end

  def check_quantity
    return if service.blank?

    if quantity < service.min_quantity
      errors.add :quantity, "should be more or equal to #{service.min_quantity}"
      return false
    end

    return if quantity <= service.max_quantity

    errors.add(:quantity, "should be less or equal to #{service.max_quantity}")
    false
  end

  def check_balance
    return if user.blank?

    return unless (user.balance - total_price).negative?

    errors.add(:base, 'Please top up your balance')
    false
  end

  def total_price
    quantity.to_f * service.price_for_thousand / 1000
  end

  def record_payment_history
    create_payment_history user: user, amount: total_price * -1, confirmed: true
  end

  def send_new_order
    @query = {}
    @query[:query] = { key: Rails.application.credentials.dig(:piar_for_you_token),
                       act: 'new_order',
                       service_id: service.code,
                       link: link_url,
                       count: quantity }

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

    update(beginning_quantity: response['start_count'])
    if aasm_state != response['status'].parameterize.underscore
      send("to_#{response['status'].parameterize.underscore}!")
    end

    delay_for(rand(120..300).seconds, retry: false).check_status(external_id)
  end

  def extra_params
    if check_timer? && service.allow_timer?
      @query.merge!(timer_likes: timer_likes, timer_interval: timer_interval)
    end
  end

  def init_check_status
    delay_for(30.seconds, retry: false).check_status(external_id)
  end

  def link_url_regexp
    if service.url_type == 'p'
      %r{(https?://(?:www\.)?instagram\.com/p/([^/?#&]+)).*}ix
    elsif service.url_type == 'tv'
      %r{(https?://(?:www\.)?instagram\.com/tv/([^/?#&]+)).*}ix
    end
  end
end
