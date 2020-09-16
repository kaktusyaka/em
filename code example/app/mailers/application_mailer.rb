class ApplicationMailer < ActionMailer::Base
  default from: "Main app <#{Setting.no_reply_email}>"
  layout 'mailer'
end
