module AuthenticationHelpers
  def sign_in_as(user, password: "password123")
    post session_path, params: { email: user.email, password: password }
  end

  def sign_in_via_ui(user, password: "password123")
    visit new_session_path
    fill_in "email", with: user.email
    fill_in "password", with: password
    click_button "Entrar"
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
  config.include AuthenticationHelpers, type: :system
end
