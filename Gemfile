source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1", group: [ :production, :development ]
# Use sqlite3 as the database for Active Record in development and test (when not using Docker)
gem "sqlite3", "~> 2.0", group: [ :development, :test ]
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Dart SASS [https://github.com/rails/dartsass-rails]
gem "dartsass-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Authentication solution for Rails [https://github.com/heartcombo/devise]
gem "devise"

# Image processing for Active Storage [https://github.com/janko/image_processing]
gem "image_processing", "~> 1.2"

# For CSV/Excel file handling
gem "roo", "~> 2.9"
gem "csv"

# For background job processing
gem "sidekiq", "~> 6.5"
gem "redis", "~> 4.8"

# For authorization (CanCanCan)
gem "cancancan"

# For pagination
gem "kaminari"

# For better forms
gem "simple_form"

# For managing environment variables
gem "dotenv-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # RSpec for testing [https://github.com/rspec/rspec-rails]
  gem "rspec-rails", "~> 7.0"

  # Factory Bot for test factories [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails"

  # Faker for generating fake data [https://github.com/faker-ruby/faker]
  gem "faker"

  # Database Cleaner for test cleanup [https://github.com/DatabaseCleaner/database_cleaner]
  gem "database_cleaner-active_record"

  # SimpleCov for code coverage [https://github.com/simplecov-ruby/simplecov]
  gem "simplecov", require: false

  # Shoulda Matchers for easier testing [https://github.com/thoughtbot/shoulda-matchers]
  gem "shoulda-matchers"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
