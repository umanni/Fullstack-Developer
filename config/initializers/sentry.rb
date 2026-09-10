# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = %i[sentry_logger active_support_logger]

  # Release It! — sample traces in production to control costs while maintaining visibility
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.1").to_f

  # Release It! — capture background job errors
  config.background_worker_threads = 5

  # Don't send personally identifiable information
  config.send_default_pii = false

  # Report only in production
  config.enabled_environments = %w[production]

  # Exclude health check from error reporting
  config.excluded_exceptions += %w[
    ActionController::RoutingError
    ActiveRecord::RecordNotFound
  ]
end
