require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "lista usuarios sem autenticacao" do
    get api_v1_users_url
    assert_response :success
  end

  test "mostra usuario sem autenticacao" do
    get api_v1_user_url(users(:admin))
    assert_response :success
  end

  test "cria usuario" do
    assert_difference "User.count" do
      post api_v1_users_url, params: { user: { full_name: "Novo User", email: "novo@example.com", password: "password123", password_confirmation: "password123" } }
    end
    assert_response :created
  end
end
