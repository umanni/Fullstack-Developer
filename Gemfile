source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3", ">= 8.1.3.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

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
gem "image_processing", "~> 1.2"

# Object-oriented authorization for Rails applications [https://github.com/varvet/pundit]
gem "pundit"

# Reads CSV and XLSX spreadsheets through a single uniform API [https://github.com/roo-rb/roo]
gem "roo"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Testing framework [https://github.com/rspec/rspec-rails]
  gem "rspec-rails"

  # Test data factories [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails"

  # Fake data generator for factories [https://github.com/faker-ruby/faker]
  gem "faker"

  # One-liner matchers for common Rails functionality [https://github.com/thoughtbot/shoulda-matchers]
  gem "shoulda-matchers"

  # Splits the test suite across parallel processes [https://github.com/grosser/parallel_tests]
  gem "parallel_tests"
end

group :test do
  # Code coverage reporting [https://github.com/simplecov-ruby/simplecov]
  gem "simplecov", require: false

  # Acceptance test framework [https://github.com/teamcapybara/capybara]
  gem "capybara"

  # Playwright driver for Capybara system tests [https://github.com/YusukeIwaki/capybara-playwright-driver]
  gem "capybara-playwright-driver"

  # RSpec matchers for testing Pundit policies [https://github.com/pundit-community/pundit-matchers]
  gem "pundit-matchers"

  # Stubs HTTP requests for testing outbound calls like AvatarFetcher [https://github.com/bblimke/webmock]
  gem "webmock"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

gem "rails-i18n", "~> 8.1"
