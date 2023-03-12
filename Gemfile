source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.1"

# Use main development branch of Rails
gem "rails", github: "rails/rails", branch: "main"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Pretty print Ruby objects with proper indentation and colors
gem "awesome_print", "~> 1.9", ">= 1.9.2"

# Use Devise for authentication
gem 'devise', '~> 4.9'

# Use Pundit for authorization
# gem 'pundit', '~> 2.3'

# Use Simple Form for forms
gem 'simple_form', '~> 5.2'

# Carrierwave for file uploads
gem 'carrierwave', '~> 2.2', '>= 2.2.3'

# Use roo for reading spreadsheets
gem 'roo', '~> 2.10'

# Use Rails Performance for performance monitoring [https://github.com/igorkasyanchuk/rails_performance]
# gem 'rails_performance', '~> 1.0', '>= 1.0.4'

# Use sideqik for background jobs
# gem 'sidekiq', '~> 7.0', '>= 7.0.6'

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # Use pry-byebug for debugging
  gem 'pry-byebug', '~> 3.10', '>= 3.10.1'

  # Use rspec for testing and handle generators
  gem 'rspec-rails', '~> 6.0', '>= 6.0.1'

  # Use Hotwire Live Reload for faster development [https://github.com/railsjazz/rails_live_reload]
  gem 'hotwire-livereload', '~> 1.2', '>= 1.2.3'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"

  # Use database_cleaner for cleaning up the database
  gem 'database_cleaner', '~> 2.0', '>= 2.0.2'

  # Use factory_bot_rails for factories
  gem 'factory_bot_rails', '~> 6.2'

  # Use faker for fake data
  gem 'faker', '~> 3.1', '>= 3.1.1'
end
