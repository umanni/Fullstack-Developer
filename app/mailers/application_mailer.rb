class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "User Management <no-reply@example.com>")
  layout "mailer"
end
