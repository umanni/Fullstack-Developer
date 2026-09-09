# Skip initialization if the required key is missing (e.g. during setup before credentials are configured)
begin
  ActiveRecord::Encryption.configure do |config|
    # Dummy deterministic key for demo/test; production must set ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY.
    # This initializer is a placeholder — real production apps must configure a secure key.
    config.deterministic_key_provider = ActiveSupport::KeyGenerator.new(
      ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "testkeytestkeytestkeytestkeytestkey")
    )
  end
rescue ActiveRecord::Encryption::Errors::Configuration => e
  Rails.logger.info("[Encryption] Skipping initialization: #{e.message}")
end
