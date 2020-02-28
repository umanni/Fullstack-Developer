require "rspec/expectations"

RSpec::Matchers.define :validate_attachment_of do |attr_name|
  match do |record|
    matcher.matches?(record, attr_name)
  end

  chain :on do |validation_context|
    matcher.on(validation_context)
  end

  chain :with_message do |message|
    matcher.with_message(message)
  end

  private

  def matcher
    @matcher ||= ValidateAttachmentOfMatcher.new
  end

  class ValidateAttachmentOfMatcher
    def on(validation_context)
      @validation_context = validation_context
    end

    def with_message(message)
      @message = message
    end

    def matches?(record, attr_name)
      record.public_send("#{attr_name}=", nil)
      record.valid?(validation_context)
      record.errors[attr_name].include? message
    end

    private

    attr_reader :validation_context

    def message
      @message || I18n.translate("activerecord.errors.messages.attached")
    end
  end
end
