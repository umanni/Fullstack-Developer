source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.3.1'
# Use postgres as the database for Active Record
gem 'pg', '1.2.3'
# Use Puma as the app server
gem 'puma', '4.3.5'
# Use SCSS for stylesheets
gem 'sass-rails', '6.0.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '4.2.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '5.2.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '2.10.0'
# Use Redis adapter to run Action Cable in production
gem 'redis', '4.1.3'
# Use dotenv-rails as environment variables manager
gem 'dotenv-rails', '2.7.5'
# Use devise as user authentication
gem 'devise', '4.7.2'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.4.6', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '11.1.3', platforms: [:mri, :mingw, :x64_mingw]
  # Use pry-rails to help debug
  gem 'pry-rails', '0.3.9'
  # Use rubocop to help with good practices
  gem 'rubocop-rails', '2.6.0'
  gem 'rubocop-performance', '1.6.1'
  # Use Rspec as the main testing framework, added on development environment to automatically handle with generators and tasks
  gem 'rspec-rails', '4.0.1'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '4.0.2'
  gem 'listen', '3.2.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '2.1.0'
  gem 'spring-watcher-listen', '2.0.1'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '3.32.2'
  gem 'selenium-webdriver', '3.142.7'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers', '4.4.1'
  # Use rspec-sidekiq to test jobs
  gem 'rspec-sidekiq', '3.0.3'
  # Use factory_bot_rails to help with the tests
  gem 'factory_bot_rails', '5.2.0'
  # Use database_cleaner to erase tests database
  gem 'database_cleaner', '1.8.5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
