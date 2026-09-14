source "https://rubygems.org"

ruby "4.0.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3", ">= 8.1.3.1"
gem "json", "~> 2.9"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

gem "inertia_rails"

# Pagination [https://github.com/ddnexus/pagy]
gem "pagy", "~> 9.0"

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

# Spreadsheet parsing (xlsx) [https://github.com/roo-rb/roo]
gem "roo", "~> 3.0"
# roo requires csv at runtime but does not declare it; no longer a default gem on Ruby 4.0
gem "csv"


# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"
# Adds `content_type` / `size` validators for Active Storage attachments (not in Rails core)
gem "active_storage_validations"

gem "faker"

group :development, :test do
  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "rspec-rails", "~> 8.0"
  # Runs the suite across CPU cores: `bundle exec parallel_rspec` [https://github.com/grosser/parallel_tests]
  gem "parallel_tests"
  gem "factory_bot_rails"
  gem "dotenv"
  gem "rubocop-rspec", require: false
  gem "erb_lint", require: false
end

group :test do
  gem "capybara"
  gem "capybara-playwright-driver"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 6.0"
  gem "simplecov", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

gem "vite_rails", "~> 3.11"

gem "aws-sdk-s3", "~> 1.231", require: false
