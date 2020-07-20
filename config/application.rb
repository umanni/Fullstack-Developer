require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module UserManager
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    
    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      g.test_framework :rspec
      g.view_specs false
      g.helper_specs false
      g.assets false
      g.helper false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Brasilia'

    config.i18n.default_locale = 'en'

    config.active_job.queue_adapter     = :sidekiq
    config.active_job.queue_name_prefix = "user_manager_#{Rails.env}"
  end
end
