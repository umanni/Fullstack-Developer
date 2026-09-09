require "rails_helper"

RSpec.describe "Locale switching" do
  describe "PATCH /locale" do
    it "remembers the choice on the account when signed in" do
      user = create(:user)
      sign_in user

      patch locale_path, params: { locale: "pt-BR" }

      expect(response).to have_http_status(:see_other)
      expect(user.reload.locale).to eq("pt-BR")
    end

    it "remembers the choice in the session for a visitor" do
      patch locale_path, params: { locale: "es" }

      get new_session_path

      expect(response.body).to include(I18n.t("sessions.new.title", locale: :es))
    end

    it "refuses a locale the application does not support" do
      user = create(:user, locale: "en")
      sign_in user

      patch locale_path, params: { locale: "de" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.locale).to eq("en")
    end

    it "returns the visitor to the page they came from" do
      patch locale_path, params: { locale: "es" }, headers: { "HTTP_REFERER" => new_registration_url }

      expect(response).to redirect_to(new_registration_url)
    end
  end

  describe "the locale applied to a request" do
    it "renders in the locale stored on the account" do
      sign_in create(:user, locale: "pt-BR")

      get profile_path

      expect(response.body).to include(I18n.t("profiles.show.title", locale: :"pt-BR"))
    end

    it "falls back to English for an account that never chose one" do
      sign_in create(:user)

      get profile_path

      expect(response.body).to include(I18n.t("profiles.show.title", locale: :en))
    end
  end
end
