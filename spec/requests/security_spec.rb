require "rails_helper"
require "English"
require "shellwords"

# A sweep by attack vector rather than by screen. The vectors each feature
# already owns -- SQL injection in the search, mass assignment of `role`, IDOR
# on the profile, a lying MIME type on an upload, an unsafe avatar URL, CSV
# injection in the rejected-rows report, the last-administrator race -- are
# covered next to those features. What is left here is what belongs to the
# application as a whole.
RSpec.describe "Security" do
  let(:administrator) { create(:user, :admin, full_name: "Ada Admin") }

  # Forgery protection is off in the test environment so that ordinary request
  # specs can post without a token. These examples need the real thing, so they
  # turn it back on around themselves.
  def with_forgery_protection
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = original
  end

  describe "cross-site request forgery" do
    it "refuses a destructive admin request that carries no token" do
      victim = create(:user)
      sign_in administrator

      with_forgery_protection do
        delete admin_user_path(victim)
      end

      expect(response).to have_http_status(:unprocessable_content)
      expect(User.exists?(victim.id)).to be(true)
    end

    it "refuses to delete an account from a forged form" do
      user = create(:user)
      sign_in user

      with_forgery_protection do
        delete profile_path
      end

      expect(response).to have_http_status(:unprocessable_content)
      expect(User.exists?(user.id)).to be(true)
    end

    it "does not destroy anything over GET" do
      victim = create(:user)
      sign_in administrator

      get "/admin/users/#{victim.id}"

      expect(response).to have_http_status(:not_found)
      expect(User.exists?(victim.id)).to be(true)
    end
  end

  describe "cross-site scripting" do
    let(:payload) { "<script>alert('xss')</script>" }

    it "escapes a name typed into the admin form wherever it is echoed back" do
      sign_in administrator

      post admin_users_path, params: {
        user: { full_name: payload, email_address: "payload@example.com", password: "a-sufficiently-long-password" }
      }
      follow_redirect!

      expect(response.body).not_to include(payload)
      expect(response.body).to include("&lt;script&gt;")
    end

    it "escapes a name that arrived through an import" do
      import_row("#{payload},imported@example.com")

      sign_in administrator
      get admin_users_path, params: { query: "imported@example.com" }

      expect(User.find_by(email_address: "imported@example.com").full_name).to eq(payload)
      expect(response.body).not_to include(payload)
      expect(response.body).to include("&lt;script&gt;")
    end

    it "escapes a name echoed inside a flash message" do
      victim = create(:user, full_name: payload)
      sign_in administrator

      delete admin_user_path(victim)
      follow_redirect!

      expect(response.body).not_to include(payload)
      expect(response.body).to include("&lt;script&gt;")
    end
  end

  describe "the session cookie" do
    it "is signed, unreadable by scripts and not sent across sites" do
      sign_in administrator

      cookie = cookie_header_for("session_id")

      expect(cookie.downcase).to include("httponly")
      expect(cookie.downcase).to include("samesite=lax")
      # The value is the signed payload, never the bare primary key.
      expect(cookie).not_to include("session_id=#{Session.last.id};")
    end

    it "is dropped on sign out, so a stolen cookie stops working" do
      sign_in administrator
      session_record = Session.last

      delete session_path

      expect(Session.exists?(session_record.id)).to be(false)

      get profile_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "response headers" do
    before { sign_in administrator }

    it "sends a content security policy that keeps injected markup inert" do
      get admin_dashboard_path

      policy = response.headers["content-security-policy"]

      expect(policy).to include("default-src 'self'", "object-src 'none'")
      expect(policy).to include("base-uri 'self'", "form-action 'self'")
      # Nothing here is meant to be framed, which is also what protects the
      # destructive admin forms from being clicked through an overlay.
      expect(policy).to include("frame-ancestors 'none'")
    end

    it "allows an inline script only with the nonce of that response" do
      get admin_dashboard_path
      first = response.headers["content-security-policy"][/'nonce-([^']+)'/, 1]

      get admin_dashboard_path
      second = response.headers["content-security-policy"][/'nonce-([^']+)'/, 1]

      expect(first).to be_present
      expect(second).not_to eq(first)
      expect(response.body).to include(%(nonce="#{second}"))
    end

    it "does not let a browser sniff a response into another content type" do
      get admin_dashboard_path

      expect(response.headers["x-content-type-options"]).to eq("nosniff")
      expect(response.headers["referrer-policy"]).to eq("strict-origin-when-cross-origin")
    end
  end

  describe "what reaches the log" do
    it "keeps credentials and reset tokens out of it" do
      user = create(:user, email_address: "logged@example.com")

      written = capturing_the_log do
        post session_path, params: { email_address: user.email_address, password: "a-sufficiently-long-password" }
      end

      expect(written).not_to include("a-sufficiently-long-password")
      expect(written).not_to include("logged@example.com")
      expect(written).to include("[FILTERED]")
    end
  end

  # The environment under test is `test`, and Rails only boots one environment
  # per process, so the production settings are read by booting a short-lived
  # production process rather than by asserting on a file's text.
  describe "the production environment" do
    it "forces SSL, which is what makes every cookie secure" do
      settings = production_settings

      expect(settings["assume_ssl"]).to be(true)
      expect(settings["force_ssl"]).to be(true)
      # The container healthcheck speaks plain http from inside the network and
      # would fail against a redirect.
      expect(settings["health_check_redirected"]).to be(false)
      expect(settings["other_paths_redirected"]).to be(true)
    end
  end

  describe "an oversized spreadsheet" do
    it "is refused before the file is attached when it is too heavy" do
      sign_in administrator
      stub_const("UserImport::MAX_FILE_BYTES", 64)

      post admin_user_imports_path, params: {
        user_import: { file: fixture_file_upload("users.csv", "text/csv") }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(UserImport.count).to be_zero
      expect(enqueued_jobs).to be_empty
    end

    it "fails the import, rather than the worker, when it holds too many rows" do
      import = create(:user_import, :with_csv, administrator: administrator)
      stub_const("UserImportParser::MAX_ROWS", 1)

      ProcessUserImportJob.perform_now(import.id)

      expect(import.reload).to be_failed
      expect(import.failure_reason).to be_present
      # The ceiling is reached while the rows are being counted, before the
      # first one is imported, so an oversized file creates nobody at all
      # rather than half a directory.
      expect(User.where(role: :user)).to be_empty
    end
  end

  private

  def production_settings
    JSON.parse(booted_in_production(<<~RUBY).lines.last.to_s)
      exclude = Rails.application.config.ssl_options.dig(:redirect, :exclude)
      request = ->(path) { ActionDispatch::Request.new("PATH_INFO" => path) }
      puts({
        assume_ssl: Rails.application.config.assume_ssl,
        force_ssl: Rails.application.config.force_ssl,
        health_check_redirected: !exclude.call(request.call("/up")),
        other_paths_redirected: !exclude.call(request.call("/admin/users"))
      }.to_json)
    RUBY
  end

  def booted_in_production(script)
    # The original env, not an unbundled one: the child runs the same Gemfile
    # from the same bundle path, only in another RAILS_ENV.
    output = Bundler.with_original_env do
      command = "RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 #{Rails.root.join("bin/rails")} runner"
      `#{command} #{Shellwords.escape(script)} 2>&1`
    end
    raise "could not boot the production environment: #{output}" unless $CHILD_STATUS.success?

    output
  end

  def cookie_header_for(name)
    Array(response.headers["set-cookie"])
      .flat_map { |header| header.split("\n") }
      .find { |header| header.start_with?("#{name}=") }
  end

  # One row through the whole import path, so an example can ask what the
  # importer does with a hostile cell without restating the plumbing.
  def import_row(row)
    import = build(:user_import, administrator: administrator)
    import.file.attach(
      io: StringIO.new("full_name,email\n#{row}\n"),
      filename: "hostile.csv",
      content_type: "text/csv"
    )
    import.save!
    ProcessUserImportJob.perform_now(import.id)
  end

  # Swaps in a logger that writes where the example can read it. The broadcast
  # logger Rails installs writes to more than one place, so both it and the
  # controller's own logger are replaced.
  def capturing_the_log
    buffer = StringIO.new
    logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(buffer))
    original_rails = Rails.logger
    original_controller = ActionController::Base.logger
    Rails.logger = logger
    ActionController::Base.logger = logger

    yield

    buffer.string
  ensure
    Rails.logger = original_rails
    ActionController::Base.logger = original_controller
  end
end
