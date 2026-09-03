module SessionTestHelper
  def sign_in_as(user)
    Current.session = user.sessions.create!(user_agent: "Rails test", ip_address: "127.0.0.1")

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end

  def valid_user_attributes(overrides = {})
    {
      full_name: "Test User",
      email: "user-#{SecureRandom.hex(4)}@example.com",
      avatar_image_url: "https://example.com/avatar.png",
      password: "SecurePass123!",
      password_confirmation: "SecurePass123!",
      role: :user
    }.merge(overrides)
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end

ActiveSupport::TestCase.include SessionTestHelper
