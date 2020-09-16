# frozen_string_literal: true

class Support::CommentMailer < ApplicationMailer
  def notify_support_team(comment)
    @comment = comment
    mail to: Setting.support_team_emails.split(', '), subject: "New Comment to Support Ticket: #{comment.commentable.subject}"
  end

  def notify_user(comment)
    @comment = comment
    mail to: @comment.user.email, subject: 'New answer for your support ticket'
  end
end
