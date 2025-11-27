# Use async adapter in development
# Use sidekiq adapter in production
Rails.application.config.active_job.queue_adapter = Rails.env.development? ? :async : :sidekiq

