# Encryption keys for ActiveRecord encryption (deterministic + primary)
# In production, set via ENV or Rails credentials; this provides a deterministic
# fallback for the test/development environment.
ActiveRecord::Encryption.configure do |config|
  # Dummy deterministic key for demo/test; production must use a real secret.
  config.deterministic_key_provider = ActiveSupport::KeyGenerator.new(
    ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "testkeytestkeytestkeytestkeytestkey")
  )
end
