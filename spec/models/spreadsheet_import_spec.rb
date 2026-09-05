require "rails_helper"

RSpec.describe SpreadsheetImport, type: :model do
  describe "validations" do
    it "requires a file to be attached" do
      spreadsheet_import = build(:spreadsheet_import)
      spreadsheet_import.file.detach

      expect(spreadsheet_import).not_to be_valid
      expect(spreadsheet_import.errors[:file]).to be_present
    end

    it "rejects an unsupported file extension" do
      spreadsheet_import = build(:spreadsheet_import)
      spreadsheet_import.file.attach(io: StringIO.new("not a spreadsheet"), filename: "notes.txt", content_type: "text/plain")

      expect(spreadsheet_import).not_to be_valid
      expect(spreadsheet_import.errors[:file]).to be_present
    end

    it "accepts a .csv file" do
      spreadsheet_import = build(:spreadsheet_import)
      spreadsheet_import.file.attach(io: StringIO.new("nome,email\n"), filename: "import.csv", content_type: "text/csv")

      expect(spreadsheet_import).to be_valid
    end

    it "accepts a .xlsx file" do
      spreadsheet_import = build(:spreadsheet_import)
      spreadsheet_import.file.attach(io: StringIO.new("bytes"), filename: "import.xlsx", content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

      expect(spreadsheet_import).to be_valid
    end

    it "rejects a file that is too large" do
      stub_const("SpreadsheetImport::MAX_BYTES", 10)
      spreadsheet_import = build(:spreadsheet_import)
      spreadsheet_import.file.attach(io: StringIO.new("x" * 20), filename: "import.csv", content_type: "text/csv")

      expect(spreadsheet_import).not_to be_valid
      expect(spreadsheet_import.errors[:file]).to be_present
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:spreadsheet_import_row_errors).dependent(:destroy) }
  end

  describe "status enum" do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, processing: 1, completed: 2, failed: 3) }
  end

  describe "#has_header" do
    it "defaults to true for a new import" do
      expect(SpreadsheetImport.new.has_header).to be true
    end
  end

  describe "#progress_percent" do
    it "is 0 when there are no rows yet" do
      spreadsheet_import = build(:spreadsheet_import, total_rows: 0, processed_rows: 0)

      expect(spreadsheet_import.progress_percent).to eq(0)
    end

    it "rounds the processed/total ratio to a whole percentage" do
      spreadsheet_import = build(:spreadsheet_import, total_rows: 3, processed_rows: 1)

      expect(spreadsheet_import.progress_percent).to eq(33)
    end
  end

  describe "background processing" do
    it "enqueues a SpreadsheetImportJob after a successful save" do
      spreadsheet_import = build(:spreadsheet_import)

      expect { spreadsheet_import.save! }.to have_enqueued_job(SpreadsheetImportJob).with(spreadsheet_import.id)
    end

    it "does not enqueue a job when the save fails" do
      spreadsheet_import = build(:spreadsheet_import)
      spreadsheet_import.file.detach

      expect { spreadsheet_import.save }.not_to have_enqueued_job(SpreadsheetImportJob)
    end
  end

  describe "progress broadcasts" do
    include ActionCable::TestHelper

    it "broadcasts when the status changes" do
      spreadsheet_import = create(:spreadsheet_import)

      expect { spreadsheet_import.update!(status: :processing) }
        .to have_broadcasted_to("spreadsheet_import_#{spreadsheet_import.id}")
    end

    it "broadcasts when total_rows changes" do
      spreadsheet_import = create(:spreadsheet_import)

      expect { spreadsheet_import.update!(total_rows: 3) }
        .to have_broadcasted_to("spreadsheet_import_#{spreadsheet_import.id}")
    end

    it "does not auto-broadcast when only processed_rows changes (throttled explicitly by the job instead)" do
      spreadsheet_import = create(:spreadsheet_import)

      expect { spreadsheet_import.update_columns(processed_rows: 1) }
        .not_to have_broadcasted_to("spreadsheet_import_#{spreadsheet_import.id}")
    end

    it "#broadcast_progress broadcasts on demand" do
      spreadsheet_import = create(:spreadsheet_import)

      expect { spreadsheet_import.broadcast_progress }
        .to have_broadcasted_to("spreadsheet_import_#{spreadsheet_import.id}")
    end

    it "does not broadcast to a different import's stream" do
      spreadsheet_import = create(:spreadsheet_import)
      other_import = create(:spreadsheet_import)

      expect { spreadsheet_import.update!(status: :processing) }
        .not_to have_broadcasted_to("spreadsheet_import_#{other_import.id}")
    end
  end
end
