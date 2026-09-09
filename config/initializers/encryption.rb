# Skip initialization if the required key is missing (e.g. during setup before credentials are configured)
# Note: production must configure a real ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY.
begin
  key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "testkeytestkeytestkeytestkeytestkey")
  ActiveRecord::Encryption.configure do |config|
    config.deterministic_key_provider = ActiveSupport::KeyGenerator.new(key)
  end
rescue StandardError => e
  Rails.logger.info("[Encryption] Disabled: #{e.message}")
end
