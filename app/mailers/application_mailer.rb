class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  after_deliver :log_to_console_in_development

  private
    # Development has no real delivery configured (see config/environments/
    # development.rb) so this is how you actually see an outgoing e-mail's link —
    # logging is safe at any volume, unlike letter_opener's per-email browser tab.
    def log_to_console_in_development
      return unless Rails.env.development?
      # message.body.to_s is empty for a multipart message (html + text parts) —
      # the readable content lives in the parts themselves, not the top-level body.
      body = message.multipart? ? message.text_part&.body : message.body
      Rails.logger.info("[Mailer] To: #{message.to&.join(', ')} — #{message.subject}\n#{body}")
    end
end
