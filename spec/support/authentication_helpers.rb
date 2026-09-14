module AuthenticationHelpers
  # Signs in through the real session endpoint so the signed cookie the
  # Authentication concern looks for is set the same way it is in production.
  def sign_in_as(user, password: "password")
    post session_url, params: { email_address: user.email_address, password: password }
    user
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
