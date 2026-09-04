require "rails_helper"

# Delivery in a real browser, over a real websocket: the page is loaded once
# and never reloaded, and the work that changes it happens afterwards, from
# the example itself. Excluded from the default run because it needs Solid
# Cable rather than the in-memory test adapter -- run it with bin/test --live.
RSpec.describe "Live updates", :js, :live do
  let(:password) { "a-sufficiently-long-password" }
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

    # A generous wait: the broadcast travels through the cable database, which
    # a spec shares with the polling thread, so delivery is measured in tenths
    # of a second rather than milliseconds.
    expect(page).to have_css("#user-counters", text: "2", wait: 15)
  end

  it "carries an import from waiting to finished without a reload" do
    import = create(:user_import, :with_csv, administrator: administrator)

    visit admin_user_import_path(import)
    expect(page).to have_text(/#{I18n.t("admin.user_imports.statuses.pending")}/i)
    wait_for_the_subscription

    ProcessUserImportJob.perform_now(import.id)

    expect(page).to have_text(/#{I18n.t("admin.user_imports.statuses.completed")}/i, wait: 15)
    expect(page).to have_current_path(admin_user_import_path(import))
  end
end
