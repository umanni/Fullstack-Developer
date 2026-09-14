class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "no-reply@umanni.test")
  layout "mailer"
end
