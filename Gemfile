source "https://rubygems.org"

gem "rails", "~> 8.1.3", ">= 8.1.3.1"

# Asset pipeline and front end
gem "importmap-rails"
gem "propshaft"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"

# Database and server
# Password hashing for the built-in Rails authentication
gem "bcrypt", "~> 3.1"

# Locale data for the shipped languages: date formats, number formats and the
# Active Record validation messages, which would otherwise stay English-only.
gem "rails-i18n", "~> 8.0"

gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

# Database-backed adapters for Rails.cache, Active Job and Action Cable.
# Solid Cable is what carries the live dashboard and import progress updates.
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

# Active Storage variants for avatars
gem "image_processing", "~> 1.2"

# Spreadsheet parsing for user imports. `csv` left the default gems in Ruby 3.4,
# so it has to be declared explicitly on Ruby 4.
gem "csv"
gem "roo", "~> 3.0"

# Pagination for the admin user list
gem "pagy", "~> 9.4"

gem "bootsnap", require: false

# Deployment
gem "kamal", require: false
gem "thruster", require: false

gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  gem "factory_bot_rails", "~> 6.5"
  gem "faker", "~> 3.5"
  gem "rspec-rails", "~> 8.0"

  # Security analysis
  gem "brakeman", require: false
  gem "bundler-audit", require: false

  # Style. The omakase preset is deliberately replaced by an explicit, stricter
  # rule set covering Rails, RSpec, Capybara and performance cops.
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
end

group :test do
  gem "capybara"
  # Cuprite drives headless Chrome over CDP directly, which keeps system specs
  # fast and removes the chromedriver version dance.
  gem "cuprite"
  gem "parallel_tests", require: false
  gem "shoulda-matchers", "~> 6.4"
  gem "simplecov", require: false
end

group :development do
  gem "web-console"
end
