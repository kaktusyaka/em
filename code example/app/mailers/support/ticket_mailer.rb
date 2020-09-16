class Support::TicketMailer < ApplicationMailer
  def new_ticket(ticket)
    @ticket = ticket
    mail to: Setting.support_team_emails.split(', '), subject: "New Support Ticket: #{ticket.subject}"
  end
end
