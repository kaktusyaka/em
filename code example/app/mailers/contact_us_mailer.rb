class ContactUsMailer < ApplicationMailer
  def send_notification(notification)
    @notification = notification
    mail to: Setting.support_team_emails.split(', '), subject: 'New Message From Contact us form'
  end
end
