require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FullstackDeveloper
  class Application < Rails::Application
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    # Set time zone
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
    
    # Set default locale to English
    config.i18n.default_locale = :en
    
    # Configure Active Storage service (will be overridden by environment files)
    config.active_storage.service = :local

    # Importmap serves JavaScript files directly from app/javascript, not through Sprockets
    # This ensures importmap can serve files without Sprockets interference
    config.importmap.sweep_cache = true

    # Generators configuration
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end
  end
end
