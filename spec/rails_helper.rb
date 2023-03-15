require 'spec_helper'
require 'support/factory_bot'
require 'support/devise'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Add color, format and documentation for the output
RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation

  # Factory Bot Configuration
  config.include FactoryBot::Syntax::Methods

  # Devise Configuration
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :request
  config.before(:suite) { Warden.test_mode! }

  # Request spec helper
  config.include RequestSpecHelper, type: :request

  # Checks for pending migrations and applies them before tests are run.
  ActiveRecord::Migration.maintain_test_schema!

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
