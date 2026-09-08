require "test_helper"

class UserImports::ProcessorTest < ActiveSupport::TestCase
  # DIP in action: the Processor receives a fake parser class (no Roo, no
  # files) and a fake broadcaster; only the default collaborators are real.
  class RecordingBroadcaster
    attr_reader :calls

    def initialize
      @calls = []
    end

    def call(user_import)
      @calls << user_import
    end
  end

  def build_fake_parser(result)
    Class.new do
      define_method(:parse) { |_file| result }
    end
  end

  def build_raising_parser(error_class, message)
    Class.new do
      define_method(:parse) { |_file| raise error_class, message }
    end
  end

  test "imports every valid row and finishes completed" do
    result = result_for(
      row(2, "Carla Nova", "carla@iam.test"),
      row(3, "Danilo Nova", "danilo@iam.test")
    )
    broadcaster = RecordingBroadcaster.new
    user_import = build_import

    UserImports::Processor.new(parser_class: build_fake_parser(result), broadcaster: broadcaster).call(user_import)

    assert user_import.completed?
    assert_equal 2, user_import.total_rows
    assert_equal 2, user_import.processed_rows
    assert_equal 0, user_import.failed_rows
    assert_not_nil user_import.finished_at
    assert_equal 2, broadcaster.calls.size
    assert_equal 2, User.where(email_address: %w[carla@iam.test danilo@iam.test]).count
  end

  test "counts invalid rows and ends failed with an aggregated summary" do
    result = result_for(
      row(2, "Carla Nova", "carla@iam.test"),
      row(3, "Só Nome", ""),
      row(4, "", "email@sem.nome")
    )
    user_import = build_import

    UserImports::Processor.new(parser_class: build_fake_parser(result)).call(user_import)

    assert user_import.failed?
    assert_equal 1, user_import.processed_rows
    assert_equal 2, user_import.failed_rows
    assert_match(/2 error\(s\) in 2 row\(s\): 3, 4\./, user_import.error_message)
    assert_equal 1, User.where(email_address: "carla@iam.test").count
  end

  test "duplicate emails are skipped as a no-op for reprocessing" do
    result = result_for(
      row(2, "Carla Nova", "reprocess@iam.test"),
      row(3, "Carla Nova Outra", "reprocess@iam.test")
    )
    user_import = build_import

    UserImports::Processor.new(parser_class: build_fake_parser(result)).call(user_import)

    assert user_import.completed?
    assert_equal 2, user_import.processed_rows
    assert_equal 0, user_import.failed_rows
    assert_equal 1, User.where(email_address: "reprocess@iam.test").count
  end

  test "fatal parser errors end failed without re-raising" do
    user_import = build_import

    UserImports::Processor.new(parser_class: build_raising_parser(IOError, "corrupt file")).call(user_import)

    assert user_import.failed?
    assert_includes user_import.error_message, "Could not process the file"
    assert_not_nil user_import.finished_at
  end

  test "broadcasts once per batch and refreshes the dashboard at the end" do
    rows = 60.times.map { |index| row(index + 2, "Batch #{index}", "batch#{index}@iam.test") }
    broadcaster = RecordingBroadcaster.new
    dashboard_updates = []
    dashboard_publisher = Class.new { define_method(:call) { dashboard_updates << :called } }.new
    user_import = build_import

    UserImports::Processor.new(
      parser_class: build_fake_parser(result_for(*rows)),
      broadcaster: broadcaster,
      dashboard_publisher: dashboard_publisher
    ).call(user_import)

    assert_equal 4, broadcaster.calls.size
    assert_equal 60, user_import.processed_rows
    assert user_import.completed?
    assert_equal 1, dashboard_updates.size
  end

  private

  def row(number, name, email)
    UserImports::Row.new(
      row_number: number,
      attributes: { full_name: name, email_address: email }
    )
  end

  def result_for(*rows)
    UserImports::Result.new(headers: %i[full_name email_address], rows: rows, total_rows: rows.size)
  end

  def build_import
    UserImport.create!(user: users(:one), status: :pending) do |record|
      record.file.attach(io: StringIO.new("Full name,Email address\n"), filename: "users.csv", content_type: "text/csv")
    end
  end
end
