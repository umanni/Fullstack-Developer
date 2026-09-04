class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "roster@example.com")
  layout "mailer"

  private

  # Mail is delivered by a worker, long after the request whose locale was the
  # reader's. Without this every message would go out in the default language,
  # whatever the person chose in their account.
  def in_the_language_of(user, &)
    I18n.with_locale(user.locale.presence || I18n.default_locale, &)
  end
end
