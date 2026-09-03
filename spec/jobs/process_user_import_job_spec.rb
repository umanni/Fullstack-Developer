require "rails_helper"

RSpec.describe ProcessUserImportJob do
  def import_for(file_name, administrator: create(:user, :admin))
    import = UserImport.new(administrator: administrator)
    import.file.attach(
      io: Rails.root.join("spec/fixtures/files/#{file_name}").open,
      filename: file_name
    )
    import.save!
    import
  end

  def run(import)
    described_class.perform_now(import.id)
    import.reload
  end

  describe "a clean file" do
    it "creates one user per row" do
      import = import_for("users.csv")

      expect { run(import) }.to change(User, :count).by(3)
    end

    it "takes the role from the file" do
      run(import_for("users.csv"))

      expect(User.find_by(email_address: "ada.admin@example.com")).to be_admin
      expect(User.find_by(email_address: "maria@example.com")).to be_user
    end

    it "records what it did" do
      import = run(import_for("users.csv"))

      expect(import).to have_attributes(
        status: "completed", total_rows: 3, processed_rows: 3, created_users: 3, rejected_rows: 0
      )
      expect(import.started_at).to be_present
      expect(import.finished_at).to be_present
    end

    it "works the same way from an XLSX" do
      import = import_for("users.xlsx")

      expect { run(import) }.to change(User, :count).by(3)
      expect(import.status).to eq("completed")
    end

    it "gives imported people an unguessable password they have to reset" do
      run(import_for("users.csv"))
      user = User.find_by(email_address: "maria@example.com")

      expect(user.authenticate("")).to be(false)
      expect(user.password_digest).to be_present
    end
  end

  describe "a file with problems" do
    subject(:import) { run(import_for("users-with-problems.csv")) }

    it "keeps going instead of stopping at the first bad row" do
      expect(import.created_users).to eq(2)
    end

    it "counts every row it looked at" do
      expect(import).to have_attributes(total_rows: 6, processed_rows: 6, rejected_rows: 4)
    end

    it "finishes in a status that says so" do
      expect(import.status).to eq("completed_with_errors")
    end

    it "records which line failed and why" do
      rejected = import.row_errors.order(:row_number)

      expect(rejected.map(&:row_number)).to eq([3, 4, 5, 6])
      expect(rejected.map(&:email_address)).to include("not-an-email", "maria@example.com")
      expect(rejected.flat_map(&:messages)).to all(be_present)
    end

    it "rejects a second row carrying an email already used earlier in the file" do
      expect(import.row_errors.map(&:email_address)).to include("maria@example.com")
      expect(User.where(email_address: "maria@example.com").count).to eq(1)
    end

    it "rejects a role it does not recognise" do
      expect(User.find_by(email_address: "role@example.com")).to be_nil
    end
  end

  describe "a file it cannot read at all" do
    subject(:import) { run(import_for("users-wrong-header.csv")) }

    it "fails as a whole" do
      expect(import.status).to eq("failed")
    end

    it "says why" do
      expect(import.failure_reason).to be_present
    end

    it "creates nobody" do
      administrator = create(:user, :admin)

      expect { run(import_for("users-wrong-header.csv", administrator: administrator)) }
        .not_to change(User, :count)
    end
  end

  describe "running the same import twice" do
    it "does not create the same people again" do
      import = import_for("users.csv")
      run(import)

      expect { run(import) }.not_to change(User, :count)
    end

    it "leaves counters describing the second run, not the sum of both" do
      import = import_for("users.csv")
      run(import)
      run(import)

      expect(import.processed_rows).to eq(3)
      expect(import.row_errors.count).to eq(3)
    end
  end

  describe "what it broadcasts" do
    def import_broadcasts(import)
      ActionCable.server.pubsub.broadcasts(import.stream_name)
    end

    def counter_broadcasts
      ActionCable.server.pubsub.broadcasts(UserCounters.stream_for("en"))
    end

    it "reports progress while it works" do
      import = import_for("users.csv")

      expect { run(import) }.to change { import_broadcasts(import).size }.by_at_least(1)
    end

    it "refreshes the dashboard totals once, not once per row" do
      import = import_for("users.csv")

      expect { run(import) }.to change(counter_broadcasts, :size).by(1)
    end
  end
end
