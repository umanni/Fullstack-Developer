class ApplicationMailer < ActionMailer::Base
  # Fallback keeps tests/console runnable; production enforces MAIL_FROM in
  # config/environments/production.rb (fail-fast).
  default from: ENV.fetch("MAIL_FROM", "no-reply@localhost")
  layout "mailer"
end
