require "rails_helper"

RSpec.describe UserImportJob, type: :job do
  include ActiveJob::TestHelper

  let(:file) do
    fixture_file_upload(
      Rails.root.join("spec/fixtures/files/users_valid.csv"),
      "text/csv"
    )
  end

  let(:import) do
    create(:import, user: create(:user), file_name: "users_valid.csv", file: file)
  end

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe "#perform" do
    it "completes import successfully" do
      UserImportJob.perform_now(import)

      import.reload
      expect(import.status).to eq("completed")
      expect(import.total_rows).to eq(10)
    end

    it "updates users if email already exists" do
      existing = create(
        :user,
        email: "joao.silva@example.com",
        full_name: "Old Name"
      )

      UserImportJob.perform_now(import)

      existing.reload
      expect(existing.full_name).not_to eq("Old Name")
    end
  end

  describe "progress broadcasting" do
    it "broadcasts progress after 10 rows" do
      allow(ActionCable.server).to receive(:broadcast)

      UserImportJob.perform_now(import)

      expect(ActionCable.server).to have_received(:broadcast).at_least(:once)
        .with(
          "import_#{import.id}",
          hash_including(type: "progress_update")
        )
    end
  end

  describe "invalid headers" do
    it "fails when required headers are missing" do
      allow_any_instance_of(Roo::CSV).to receive(:row).with(1)
        .and_return([ "wrong_header" ])

      expect {
        UserImportJob.perform_now(import)
      }.to raise_error(/Missing required headers/)
    end
  end
end
