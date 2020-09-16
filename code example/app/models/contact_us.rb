# frozen_string_literal: true

class ContactUs < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255, minimum: 3 }
  validates :email, format: { with: Devise.email_regexp }
  validates :message, presence: true, length: { maximum: 65_536 }

  geocoded_by :ip_address
  after_validation :geocode, unless: -> { ip_address.blank? }

  after_create :send_notification

  private

  def send_notification
    ContactUsMailer.delay.send_notification(self)
  end
end
