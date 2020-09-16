class Support::Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user, optional: true

  has_rich_text :description
  has_many_attached :files

  scope :asc, -> { order(created_at: :asc) }

  validates :user, presence: true, if: -> { user_id.present? }
  validates :description, presence: true, length: { maximum: 65_536 }
  validates :files, size: { less_than_or_equal_to: 10.megabytes }

  after_create :notify_support_team, :notify_user, :update_ticket_status

  def from_support_team?
    user.blank?
  end

  def from_user?
    user
  end

  def for_support_team?
    from_user?
  end

  def for_user?
    from_support_team?
  end

  private

  def notify_support_team
    return if user

    Support::CommentMailer.delay.notify_support_team(self)
  end

  def notify_user
    return if user.blank?

    Support::CommentMailer.delay.notify_user(self)
  end

  def update_ticket_status
    ticket = commentable

    ticket.wait! if from_user? && ticket.answered?
    ticket.answer! if from_support_team?
  end
end
