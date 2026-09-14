require "rails_helper"
require "active_job/continuation/test_helper"

RSpec.describe ProcessImportJob, type: :job do
  include ActiveJob::Continuation::TestHelper

  let(:progress) { [] }

  # A recorder stands in for Imports::ProgressBroadcaster so the status and row
  # count each broadcast would have announced can be checked, in order.
  before do
    snapshots = progress
    stub_const("Imports::ProgressBroadcaster", Module.new do
      define_singleton_method(:call) { |import| snapshots << [ import.status, import.processed_rows ] }
    end)
  end

  def csv(*emails)
    lines = emails.map { |email| "#{email.split("@").first.capitalize} Person,#{email}" }
    ([ "name,email" ] + lines).join("\n") + "\n"
  end

  def emails(count) = (1..count).map { "row#{_1}@example.com" }

  def import_with(content)
    create(:import).tap do |import|
      import.file.attach(io: StringIO.new(content), filename: "users.csv", content_type: "text/csv")
    end
  end

  it "runs on the imports queue" do
    expect(described_class.new.queue_name).to eq("imports")
  end

  describe "a clean run" do
    before { create(:user, email_address: "taken@example.com") }

    let!(:import) { import_with(csv("new1@example.com", "taken@example.com", "not-an-email", "new2@example.com")) }

    it "creates, skips and fails rows and keeps the tallies" do
      expect { described_class.perform_now(import) }.to change(User, :count).by(2)

      expect(import.reload).to have_attributes(
        status: "completed", total_rows: 4, processed_rows: 4,
        created_count: 2, skipped_count: 1, failed_count: 1
      )
      expect(import.started_at).to be_present
      expect(import.finished_at).to be >= import.started_at
    end

    it "reports each failed row with its index and email" do
      described_class.perform_now(import)

      expect(import.reload.error_report).to contain_exactly(
        a_hash_including("row" => 3, "identifier" => "not-an-email", "errors" => include("Email address is invalid"))
      )
    end

    it "broadcasts progress once counted, after the rows, and when done" do
      described_class.perform_now(import)

      expect(progress).to eq([ [ "processing", 0 ], [ "processing", 4 ], [ "completed", 4 ] ])
    end

    it "notifies the dashboard once rather than once per created user" do
      expect { described_class.perform_now(import) }
        .to have_broadcasted_to(Dashboard::Broadcaster::STREAM).exactly(:once)
    end
  end

  describe "working in batches" do
    before { stub_const("ProcessImportJob::BATCH_SIZE", 2) }

    let!(:import) { import_with(csv(*emails(5))) }

    it "saves progress after every full batch and after the last partial one" do
      described_class.perform_now(import)

      expect(progress).to eq([
        [ "processing", 0 ], [ "processing", 2 ], [ "processing", 4 ], [ "processing", 5 ], [ "completed", 5 ]
      ])
    end

    it "resumes after the last saved batch when interrupted, without redoing rows" do
      described_class.perform_later(import)

      interrupt_job_during_step(described_class, :import_rows, cursor: 2) { perform_enqueued_jobs }

      expect(import.reload).to have_attributes(status: "processing", processed_rows: 2, created_count: 2)

      perform_enqueued_jobs

      expect(import.reload).to have_attributes(
        status: "completed", processed_rows: 5, created_count: 5, skipped_count: 0
      )
    end
  end

  it "leaves an import that has already finished alone" do
    import = import_with(csv("new1@example.com"))
    import.update!(status: :completed)

    expect { described_class.perform_now(import) }.not_to change(User, :count)
    expect(progress).to be_empty
  end

  it "completes a file that has a header and no rows" do
    import = import_with("name,email\n")

    described_class.perform_now(import)

    expect(import.reload).to have_attributes(status: "completed", total_rows: 0, processed_rows: 0)
  end

  describe "a file it cannot read" do
    let!(:import) { import_with("department,office\nEngineering,London\n") }

    it "marks the import failed with the reason, then lets the error through" do
      expect { described_class.perform_now(import) }.to raise_error(Imports::RowSet::MalformedFile)

      expect(import.reload).to have_attributes(status: "failed", failure_reason: "No recognisable columns found")
      expect(import.finished_at).to be_present
      expect(progress.last).to eq([ "failed", 0 ])
    end
  end

  it "discards the job when the import has since been deleted" do
    import = import_with(csv("new1@example.com"))
    described_class.perform_later(import)
    import.delete

    expect { perform_enqueued_jobs }.not_to raise_error
  end
end
