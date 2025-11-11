require "sidekiq"
require "sidekiq/web"

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5
  }

  # Configure the number of threads
  config.concurrency = ENV.fetch("SIDEKIQ_CONCURRENCY", 5).to_i
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5
  }
end

# Configure queues
Sidekiq.default_job_options = {
  "backtrace" => true,
  "retry" => 3
}
