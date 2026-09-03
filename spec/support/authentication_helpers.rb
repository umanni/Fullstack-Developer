module AuthenticationHelpers
  DEFAULT_PASSWORD = "a-sufficiently-long-password".freeze

  def sign_in(user, password: DEFAULT_PASSWORD)
    post session_path, params: { email_address: user.email_address, password: password }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
  config.include AuthenticationHelpers, type: :system
end
