# Active Record Encryption for sensitive columns (e.g. email_address).
# Production keys live in Rails credentials under active_record_encryption.
# Local/test keys are fixed so seeds, fixtures, and CI work without ceremony.

Rails.application.configure do
  credentials_keys = Rails.application.credentials.active_record_encryption

  if credentials_keys.present?
    config.active_record.encryption.primary_key = credentials_keys[:primary_key]
    config.active_record.encryption.deterministic_key = credentials_keys[:deterministic_key]
    config.active_record.encryption.key_derivation_salt = credentials_keys[:key_derivation_salt]
  elsif Rails.env.local? || ENV["SECRET_KEY_BASE_DUMMY"].present?
    # Local defaults, plus Docker asset-precompile (SECRET_KEY_BASE_DUMMY=1).
    config.active_record.encryption.primary_key = "umanniLocalPrimaryKey32chars!!"
    config.active_record.encryption.deterministic_key = "umanniLocalDeterministicKey32!"
    config.active_record.encryption.key_derivation_salt = "umanniLocalDerivationSalt32chr"
  else
    raise "Missing credentials.active_record_encryption keys for #{Rails.env}. " \
          "Add them with bin/rails credentials:edit (see README)."
  end

  # Allows reading legacy plaintext rows during local upgrades / first migrate.
  config.active_record.encryption.support_unencrypted_data = Rails.env.local?
end
