require "rails_helper"

# A browser whose locale and time zone differ from the SSR server's (en-US, UTC), so any markup
# that formats dates or numbers differently on each side shows up as a hydration error.
Capybara.register_driver(:playwright_pt_br) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :chromium, headless: true,
                                        locale: "pt-BR", timezoneId: "America/Sao_Paulo")
end

RSpec.describe "Server-side rendering", type: :system do
  let(:admin) { create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com") }

  around do |example|
    SsrServer.start
    InertiaRails.configuration.ssr_enabled = true
    example.run
  ensure
    InertiaRails.configuration.ssr_enabled = false
  end

  it "sends the rendered page in the HTML, before any JavaScript runs" do
    visit new_registration_path

    expect(page).to have_css("#app[data-server-rendered]")
    expect(page).to have_field("Full name")
    expect(page).to have_title("Create account")
    expect(page.all("title", visible: :all).size).to eq(1)
  end

  it "falls back to rendering in the browser when the SSR server can't be reached" do
    InertiaRails.configuration.ssr_url = "http://localhost:1"
    visit new_registration_path

    expect(page).to have_css("#app", visible: :all)
    expect(page).to have_no_css("#app[data-server-rendered]", visible: :all)
  ensure
    InertiaRails.configuration.ssr_url = nil
  end

  describe "in the browser", :js do
    before { driven_by :playwright_pt_br }

    def sign_in_through_the_form(user)
      visit new_session_path
      fill_in "email_address", with: user.email_address
      fill_in "password", with: "password"
      click_on "Sign in"
      expect(page).to have_no_current_path(new_session_path, wait: 5)
    end

    def collect_browser_errors
      [].tap do |errors|
        page.driver.with_playwright_page do |browser_page|
          browser_page.on("console", ->(message) { errors << message.text if message.type == "error" })
          browser_page.on("pageerror", ->(error) { errors << error.message })
        end
      end
    end

    it "hydrates pages with dates without mismatches, then shows them in the visitor's locale" do
      sign_in_through_the_form(admin)
      errors = collect_browser_errors

      visit admin_dashboard_path
      expect(page).to have_css("h1", text: "Admin dashboard")

      visit admin_user_path(admin)
      expect(page).to have_css("time", text: /de \d{4}/)
      expect(errors).to be_empty
    end
  end
end
