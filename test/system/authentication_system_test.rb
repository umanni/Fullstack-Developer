require "application_system_test_case"

class AuthenticationSystemTest < ApplicationSystemTestCase
  test "member signs in and lands on profile" do
    visit new_session_path
    fill_in "email", with: users(:member).email
    fill_in "password", with: "password123"
    click_button "Entrar"

    assert_text "Perfil"
    assert_text users(:member).full_name
  end

  test "admin signs in and lands on dashboard" do
    visit new_session_path
    fill_in "email", with: users(:admin).email
    fill_in "password", with: "password123"
    click_button "Entrar"

    assert_text "Painel"
    assert_text "Total de usuários"
  end

  test "visitor can register" do
    visit new_registration_path
    fill_in "user_full_name", with: "Visitante Sistema"
    fill_in "user_email", with: "system.visitor@example.com"
    fill_in "user_password", with: "password123"
    fill_in "user_password_confirmation", with: "password123"
    click_button "Criar conta"

    assert_text "Perfil"
    assert_text "Visitante Sistema"
  end
end
