require "active_support/core_ext/integer/time"

Rails.application.configure do
  app_host = ENV.fetch("APP_HOST", "example.com")
  app_protocol = ENV.fetch("APP_PROTOCOL", "https")
  credentials_available = ENV["RAILS_MASTER_KEY"].present? || Rails.root.join("config/master.key").exist?
  smtp_credentials = credentials_available ? Rails.application.credentials.fetch(:smtp, {}) : {}
  config.yjit = false if ENV["RUBYOPT"].to_s.split.include?("--zjit")
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  if app_protocol == "https"
    config.assume_ssl = true
    config.force_ssl = true
    config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
  end

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = {
    host: app_host,
    protocol: app_protocol
  }

  smtp_address = ENV["SMTP_ADDRESS"].presence || smtp_credentials[:address]
  if smtp_address.present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
      address: smtp_address,
      port: ENV.fetch("SMTP_PORT", smtp_credentials[:port] || 587),
      user_name: ENV["SMTP_USERNAME"].presence || smtp_credentials[:user_name],
      password: ENV["SMTP_PASSWORD"].presence || smtp_credentials[:password],
      authentication: :plain,
      enable_starttls_auto: true
    }.compact
  else
    # Keeps the production-like Docker demo self-contained. Real deployments
    # should supply SMTP credentials and will automatically switch to SMTP.
    config.action_mailer.delivery_method = :file
    config.action_mailer.file_settings = { location: Rails.root.join("storage/mails") }
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  config.hosts = [ app_host ]
  config.hosts << "localhost" if app_host == "localhost"
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
