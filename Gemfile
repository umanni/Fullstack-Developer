# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

gem 'rails', '~> 6.0.2', '>= 6.0.2.1'

gem 'activeadmin', '~> 2.6', '>= 2.6.1'
gem 'activeadmin-async_panel'
gem 'activeadmin_addons', '~> 1.7', '>= 1.7.1'
gem 'arctic_admin', '~> 3.1', '>= 3.1.1'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise', '~> 4.7', '>= 4.7.1'
gem 'image_processing'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

# Downgraded sprockets because of a bug with sprocket-4.0
# https://tosbourn.com/fixing-an-issue-with-sprockets-and-feature-tests/
gem 'sprockets', '~> 3.7.2'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

group :development, :test do
  gem 'awesome_print', '~> 1.8'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '~> 2.7', '>= 2.7.5'
  gem 'factory_bot_rails', '~> 5.1', '>= 5.1.1'
  gem 'faker', '~> 2.10', '>= 2.10.2'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.9'
  gem 'rubocop-rails', '~> 2.4', '>= 2.4.2', require: false
  gem 'rubocop-rspec', '~> 1.38', '>= 1.38.1', require: false
end

group :development do
  gem 'better_errors', '~> 2.5', '>= 2.5.1'
  gem 'binding_of_caller', '~> 0.8.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'apparition', '~> 0.5.0'
  gem 'capybara', '~> 3.31'
  gem 'capybara-screenshot', '~> 1.0', '>= 1.0.24'
  gem 'shoulda-matchers', '~> 4.3'
  gem 'simplecov', '~> 0.17.1', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
