require "rails_helper"

# Delivery in a real browser, over a real websocket: the page is loaded once
# and never reloaded, and the work that changes it happens afterwards, from
# the example itself. Excluded from the default run because it needs Solid
# Cable rather than the in-memory test adapter -- run it with bin/test --live.
RSpec.describe "Live updates", :js, :live do
  let(:password) { "a-sufficiently-long-password" }
  # Delivery travels through a polling loop on the cable database, and a busy
  # CI machine is slower than a laptop, so the waits here are generous. They
  # cost nothing when the update arrives, which is the ordinary case.
  let(:delivery_wait) { 25 }
  let(:administrator) do
    create(:user, :admin, full_name: "Ada Lovelace", email_address: "ada@example.com", password: password)
  end

  before do
    visit new_session_path
    fill_in "Email address", with: administrator.email_address
    fill_in "Password", with: password
    click_on "Sign in"
    has_current_path?(admin_dashboard_path, wait: 5)
  end

  # Solid Cable delivers what is published after a subscription exists, so a
  # broadcast sent while the browser is still connecting is simply missed.
  # Turbo marks its stream source element `connected` once the subscription is
  # confirmed, which is the moment the page is really listening.
  def wait_for_the_subscription
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)
  end

  it "moves the dashboard counters when somebody else changes the roster" do
    # The labels are uppercased by CSS, so they are matched without case.
    expect(page).to have_text(/total users/i)
    expect(page).to have_css("#user-counters", text: "1")
    wait_for_the_subscription

    create(:user, full_name: "Maria Silva")

    expect(page).to have_css("#user-counters", text: "2", wait: delivery_wait)
  end

  it "carries an import from waiting to finished without a reload" do
    import = create(:user_import, :with_csv, administrator: administrator)

    visit admin_user_import_path(import)
    expect(page).to have_text(/#{I18n.t("admin.user_imports.statuses.pending")}/i)
    wait_for_the_subscription

    ProcessUserImportJob.perform_now(import.id)

    expect(page).to have_text(/#{I18n.t("admin.user_imports.statuses.completed")}/i, wait: delivery_wait)
    expect(page).to have_current_path(admin_user_import_path(import))
  end
end
