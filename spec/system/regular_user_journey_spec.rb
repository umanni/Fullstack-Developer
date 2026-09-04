require "rails_helper"

# What a person with an ordinary account can do from end to end, and where the
# application stops them.
RSpec.describe "The regular user journey" do
  let(:password) { "a-sufficiently-long-password" }
  let!(:user) do
    create(:user, full_name: "Maria Silva", email_address: "maria@example.com", password: password)
  end

  def sign_in_as(email_address)
    visit new_session_path
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    click_on "Sign in"
  end

  it "signs in, corrects their own details and sees the change" do
    sign_in_as(user.email_address)

    expect(page).to have_current_path(profile_path)

    click_on "Edit profile"
    fill_in "Full name", with: "Maria Silva Santos"
    fill_in "Avatar URL", with: "https://example.com/maria.png"
    click_on "Save changes"

    expect(page).to have_text(I18n.t("profiles.updated"))
    expect(page).to have_text("Maria Silva Santos")
    expect(user.reload.full_name).to eq("Maria Silva Santos")
  end

  it "is refused an avatar URL that is not an ordinary web link" do
    sign_in_as(user.email_address)

    visit edit_profile_path
    fill_in "Avatar URL", with: "javascript:alert('xss')"
    click_on "Save changes"

    expect(page).to have_text("must be an http or https link")
    expect(user.reload.avatar_url).to be_nil
  end

  it "keeps the language they chose, because it belongs to the account" do
    sign_in_as(user.email_address)

    choose_language("Português")

    expect(page).to have_text("Meu perfil")
    expect(user.reload.locale).to eq("pt-BR")

    # The sign out button appears in the sidebar and again in the mobile bar.
    click_on "Sair", match: :first
    # Back to English as a visitor, so what comes next cannot be the session
    # remembering the choice -- it has to come from the account.
    choose_language("English")
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: password
    click_on "Sign in"

    expect(page).to have_text("Meu perfil")
  end

  it "is turned away from the administration area, plainly" do
    sign_in_as(user.email_address)

    visit admin_users_path

    expect(page).to have_current_path(profile_path)
    expect(page).to have_text(I18n.t("authorization.admin_only"))
  end

  it "cannot reach another person's profile, because there is no URL to try" do
    other = create(:user, full_name: "Someone Else")
    sign_in_as(user.email_address)

    visit profile_path

    expect(page).to have_text("Maria Silva")
    expect(page).to have_no_text(other.full_name)
  end

  it "deletes their own account and cannot get back in" do
    sign_in_as(user.email_address)

    click_on "Delete my account"

    expect(page).to have_current_path(new_session_path)
    expect(page).to have_text(I18n.t("profiles.deleted"))

    sign_in_as("maria@example.com")

    expect(page).to have_text(I18n.t("sessions.invalid_credentials"))
    expect(User.find_by(email_address: "maria@example.com")).to be_nil
  end
end
