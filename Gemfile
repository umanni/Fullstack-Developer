source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.6'

gem 'rails', '~> 8.0.3'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.4'
gem 'sass-rails', '~> 6.0'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder', '~> 2.13'
gem 'bootsnap', '>= 1.4.4', require: false

# Authentication
gem 'devise'

# Authorization
gem 'pundit'

# Background Jobs
gem 'sidekiq', '~> 7.2'
gem 'redis', '~> 5.0'

# File Upload
gem 'image_processing', '~> 1.12'
gem 'mini_magick'

# Spreadsheet Import
gem 'roo', '~> 2.10'
gem 'roo-xls'

# Bootstrap
gem 'bootstrap', '~> 5.3'
gem 'jquery-rails'
gem 'popper_js', '~> 2.11'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'shoulda-matchers', '~> 6.3'
  gem 'database_cleaner-active_record', '~> 2.2'
  gem 'simplecov', require: false
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '>= 4.11'
  gem 'rails-controller-testing', '~> 1.0'
end

group :development do
  gem 'web-console', '>= 4.2.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'rubocop', '~> 1.64', require: false
  gem 'rubocop-rails', '~> 2.24', require: false
  gem 'rubocop-rspec', '~> 2.26', require: false
end

group :test do
  gem 'webmock', '~> 3.23'
  gem 'vcr', '~> 6.3'
end

