# frozen_string_literal: true

class Support::Ticket < ApplicationRecord
  include AASM

  has_rich_text :description

  belongs_to :user

  has_many :comments, as: :commentable, dependent: :destroy
  has_many_attached :files

  validates :user, presence: true
  validates :subject, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 65_536 }
  validates :files, size: { less_than_or_equal_to: 10.megabytes }

  COLORS = { opened: 'label-warning', answered: 'label-info',
             closed: 'label-success', waiting: 'label-primary' }.freeze

  scope :desc, -> { reorder(id: :desc) }

  after_create :notify_support_team

  aasm do
    state :opened, initial: true
    state :answered
    state :waiting
    state :closed

    event :answer do
      transitions from: :open, to: :answered
    end

    event :close do
      transitions from: %i[open waiting answer], to: :closed
    end

    event :wait do
      transitions from: :answered, to: :waiting
    end
  end

  private

  def notify_support_team
    Support::TicketMailer.delay.new_ticket(self)
  end
end
