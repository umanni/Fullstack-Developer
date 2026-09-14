require "test_helper"

class SpreadsheetImportJobTest < ActiveJob::TestCase
  test "imports the valid rows of a csv and reports the rest" do
    import = build_import("users.csv")

    assert_difference -> { User.count }, 3 do
      SpreadsheetImportJob.perform_now(import)
    end

    import.reload

    assert_predicate import, :completed?
    assert_equal 5, import.total_rows
    assert_equal 5, import.processed_rows
    assert_equal 2, import.failed_rows
    assert_equal 3, import.imported_rows
    assert_equal 100, import.progress
  end

  test "imports an xlsx exactly as it imports a csv" do
    import = build_import("users.xlsx")

    assert_difference -> { User.count }, 3 do
      SpreadsheetImportJob.perform_now(import)
    end

    assert_equal 2, import.reload.failed_rows
  end

  test "names the line and the reason for every row it could not import" do
    import = build_import("users.csv")

    SpreadsheetImportJob.perform_now(import)

    errors = import.reload.row_errors

    assert_equal [ 5, 6 ], errors.map { |row_error| row_error["line"] }
    assert_match "Full name can't be blank", errors.first["message"]
    assert_match "Email has already been taken", errors.second["message"]
  end

  test "assigns the role from the file, defaulting anything unrecognised to user" do
    import = build_import("users.csv")

    SpreadsheetImportJob.perform_now(import)

    assert_predicate User.find_by(email: "katherine@umanni.test"), :admin?
    assert_predicate User.find_by(email: "dorothy@umanni.test"), :user?
    # Blank role in the file.
    assert_predicate User.find_by(email: "mary@umanni.test"), :user?
  end

  # Comparing the two digests proves nothing: bcrypt salts every call, so the same
  # password twice still yields different digests. Watch what the password is drawn from.
  test "gives imported people an unguessable password rather than a shared one" do
    import = build_import("users.csv")
    drawn = []
    original = SecureRandom.method(:base58)
    SecureRandom.define_singleton_method(:base58) { |n = 16| original.call(n).tap { |value| drawn << value } }

    begin
      SpreadsheetImportJob.perform_now(import)
    ensure
      SecureRandom.define_singleton_method(:base58, original)
    end

    katherine = User.find_by(email: "katherine@umanni.test")
    dorothy = User.find_by(email: "dorothy@umanni.test")
    hers = drawn.find { |value| katherine.authenticate(value) }
    theirs = drawn.find { |value| dorothy.authenticate(value) }

    assert hers, "no freshly drawn value opens the account, so the password came from somewhere else"
    assert_not_equal hers, theirs, "two imported people were given the same password"
  end

  # Without the cursor, a restarted worker replays imported rows as duplicate emails.
  test "resumes from its cursor rather than replaying imported rows" do
    import = build_import("users.csv")
    import.update!(status: :processing, total_rows: 5, processed_rows: 2)
    %w[ katherine dorothy ].each do |name|
      User.create!(
        full_name: name.capitalize, email: "#{name}@umanni.test",
        password: "secret-password", password_confirmation: "secret-password"
      )
    end

    assert_difference -> { User.count }, 1 do
      perform_resumed(import, completed: %w[ prepare ], current: [ "import_rows", 2 ])
    end

    assert_predicate import.reload, :completed?
    assert_not_nil User.find_by(email: "mary@umanni.test"), "the row at the cursor was skipped"
    assert_equal 2, import.failed_rows
  end

  test "treats a row lost to a uniqueness race as rejected, not fatal" do
    import = build_import("users.csv")
    raced = false
    racer = lambda do |user|
      next if raced || user.email != "dorothy@umanni.test"

      raced = true
      User.create!(full_name: "Race Winner", email: user.email,
                   password: "secret-password", password_confirmation: "secret-password")
    end
    User.set_callback(:create, :before, racer)

    SpreadsheetImportJob.perform_now(import)
    import.reload

    assert raced, "the race never happened, so this test proved nothing"
    assert_predicate import, :completed?
    assert_includes import.row_errors.map { |row| row["message"] }, "Email has already been taken"
    assert_equal 5, import.processed_rows
  ensure
    User.skip_callback(:create, :before, racer)
  end

  test "fails with a readable reason when the file has no email column" do
    path = Rails.root.join("tmp", "semicolons-#{SecureRandom.hex(4)}.csv")
    path.write("full_name;email;role\nAda Lovelace;ada.semi@umanni.test;user\n")
    import = users(:admin).spreadsheet_imports.create!(file: { io: path.open, filename: "semi.csv" })

    assert_raises ArgumentError do
      SpreadsheetImportJob.perform_now(import)
    end

    assert_predicate import.reload, :failed?
    assert_match "no `email` column", import.failure_reason
  ensure
    path&.delete
  end

  # An all-bad file would otherwise rewrite an ever-growing JSON column once per row
  # and carry the whole list in every broadcast.
  test "stops listing reasons past the cap but keeps counting" do
    cap = SpreadsheetImportJob::MAX_ROW_ERRORS
    path = Rails.root.join("tmp", "many-bad-#{SecureRandom.hex(4)}.csv")
    path.write((%w[full_name,email,role] + Array.new(cap + 20) { ",,user" }).join("\n"))
    import = users(:admin).spreadsheet_imports.create!(file: { io: path.open, filename: "bad.csv" })

    SpreadsheetImportJob.perform_now(import)
    import.reload

    assert_equal cap + 20, import.failed_rows
    assert_equal cap, import.row_errors.size
    assert_equal 20, import.unlisted_failures
  ensure
    path&.delete
  end

  test "marks the import failed, records why, and re-raises when the file cannot be read" do
    import = build_import("not-an-image.txt", skip_validation: true)

    error = assert_raises StandardError do
      SpreadsheetImportJob.perform_now(import)
    end

    import.reload

    # StandardError on its own would also accept a NoMethodError introduced right here.
    assert_not_kind_of NameError, error
    assert_predicate import, :failed?
    # A red badge with no reason sends the admin to a jobs table to find out what broke.
    assert_equal "#{error.class}: #{error.message}".truncate(500), import.failure_reason
  end

  test "reads a capitalised role as the role it obviously is" do
    path = Rails.root.join("tmp", "roles-#{SecureRandom.hex(4)}.csv")
    path.write("full_name,email,role\nKatherine Johnson,katherine@umanni.test,Admin\n")
    import = users(:admin).spreadsheet_imports.create!(file: { io: path.open, filename: "roles.csv" })

    SpreadsheetImportJob.perform_now(import)

    assert_predicate User.find_by(email: "katherine@umanni.test"), :admin?
    assert_equal 0, import.reload.failed_rows
  ensure
    path&.delete
  end

  # Guards the pacing, not the suppression around it: turbo-rails debounces immediately
  # in test, so removing User.suppressing_turbo_broadcasts leaves this green.
  test "refreshes the dashboard while a long import runs, not only at the end" do
    import = build_import("bulk_users.csv")

    refreshes = count_dashboard_refreshes { SpreadsheetImportJob.perform_now(import) }

    assert_operator refreshes, :>, 1, "the dashboard was refreshed only once, at the end"
  end

  private
    # By hand: Minitest 6 dropped minitest/mock, and turbo's helper needs the :test
    # cable adapter, which this suite does not use.
    def count_dashboard_refreshes
      count = 0
      original = Turbo::StreamsChannel.method(:broadcast_refresh_to)

      Turbo::StreamsChannel.define_singleton_method(:broadcast_refresh_to) do |*args, **options|
        count += 1
        original.call(*args, **options)
      end

      yield
      count
    ensure
      Turbo::StreamsChannel.singleton_class.remove_method(:broadcast_refresh_to)
    end

    def perform_resumed(import, completed:, current:)
      job = SpreadsheetImportJob.new(import)
      job.deserialize(job.serialize.merge("continuation" => { "completed" => completed, "current" => current }))
      job.perform_now
    end

    def build_import(fixture, skip_validation: false)
      import = users(:admin).spreadsheet_imports.new
      import.file.attach(io: file_fixture(fixture).open, filename: fixture)
      skip_validation ? import.save!(validate: false) : import.save!
      import
    end
end
