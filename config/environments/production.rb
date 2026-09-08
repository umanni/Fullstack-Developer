require "active_support/core_ext/integer/time"

Rails.application.configure do
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
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
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

  # Mail delivery: raise_delivery_errors is enabled when SMTP is configured below.

  # Absolute URL base for mailer links (password reset). Fail-fast: APP_HOST
  # is required in production, supplied by the deploy environment (.env/Kamal).
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST"),
    protocol: ENV.fetch("APP_PROTOCOL", "https"),
    port: ENV["APP_PORT"]
  }.compact

  # The mailer sender is required in production — no silently-wrong fallback.
  raise "MAIL_FROM is required in production (see .env.example)" if ENV["MAIL_FROM"].blank?

  # SMTP transport is optional and activated only when SMTP_HOST is provided.
  # Without it, password-reset emails cannot be delivered, so fail loudly.
  if ENV["SMTP_HOST"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_HOST"),
      port: Integer(ENV.fetch("SMTP_PORT", 587)),
      user_name: ENV["SMTP_USER"],
      password: ENV["SMTP_PASSWORD"],
      authentication: (ENV.fetch("SMTP_AUTH", "plain") || "plain").to_sym,
      starttls_auto: ENV.fetch("SMTP_STARTTLS_AUTO", "true") == "true"
    }
  else
    config.action_mailer.delivery_method = :test
    Rails.logger&.warn "SMTP_HOST is not set: mail delivery is disabled (password reset will not reach recipients)."
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [ ENV.fetch("APP_HOST") ]
  # Allow the health check to be reached without a matching Host header.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
