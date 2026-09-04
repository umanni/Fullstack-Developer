# Active Record Encryption for sensitive columns (e.g. email_address).
#
# Key lookup order:
# 1. credentials.active_record_encryption
# 2. ACTIVE_RECORD_ENCRYPTION_* environment variables
# 3. Keys derived from secret_key_base (so Docker only needs RAILS_MASTER_KEY)
# 4. Fixed local keys for development/test and SECRET_KEY_BASE_DUMMY asset builds

module UmanniEncryptionKeys
  module_function

  def apply!(config)
    keys = if Rails.env.local? || dummy_secret_key_base?
      local_keys.merge(from_env)
    else
      from_secret_key_base.merge(from_credentials).merge(from_env)
    end

    if complete?(keys)
      assign!(config, keys)
    else
      raise "Missing Active Record encryption keys for #{Rails.env}. " \
            "Pass RAILS_MASTER_KEY (or ACTIVE_RECORD_ENCRYPTION_*). See README."
    end

    config.active_record.encryption.support_unencrypted_data = Rails.env.local?
  end

  def dummy_secret_key_base?
    ENV["SECRET_KEY_BASE_DUMMY"].present?
  end

  def from_credentials
    creds = Rails.application.credentials.active_record_encryption
    return {} if creds.blank?

    {
      primary_key: creds[:primary_key],
      deterministic_key: creds[:deterministic_key],
      key_derivation_salt: creds[:key_derivation_salt]
    }.compact_blank
  end

  def from_env
    {
      primary_key: ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"].presence,
      deterministic_key: ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"].presence,
      key_derivation_salt: ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"].presence
    }.compact_blank
  end

  def from_secret_key_base
    secret = Rails.application.secret_key_base.to_s
    return {} if secret.blank? || ENV["SECRET_KEY_BASE_DUMMY"].present?

    require "openssl"
    {
      primary_key: OpenSSL::HMAC.hexdigest("SHA256", secret, "umanni/ar-primary")[0, 32],
      deterministic_key: OpenSSL::HMAC.hexdigest("SHA256", secret, "umanni/ar-deterministic")[0, 32],
      key_derivation_salt: OpenSSL::HMAC.hexdigest("SHA256", secret, "umanni/ar-salt")[0, 32]
    }
  end

  def local_keys
    {
      primary_key: "umanniLocalPrimaryKey32chars!!",
      deterministic_key: "umanniLocalDeterministicKey32!",
      key_derivation_salt: "umanniLocalDerivationSalt32chr"
    }
  end

  def complete?(keys)
    keys[:primary_key].present? && keys[:deterministic_key].present? && keys[:key_derivation_salt].present?
  end

  def assign!(config, keys)
    config.active_record.encryption.primary_key = keys[:primary_key]
    config.active_record.encryption.deterministic_key = keys[:deterministic_key]
    config.active_record.encryption.key_derivation_salt = keys[:key_derivation_salt]
  end
end

Rails.application.configure do
  UmanniEncryptionKeys.apply!(config)
end
