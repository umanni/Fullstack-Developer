require 'rails_helper'

RSpec.describe ImportUsersJob, type: :job do
  include ActiveJob::TestHelper

  # Factory for user_import (requires a file attachment)
  FactoryBot.define do
    factory :user_import do
      # Attach a real file from your 'spec/fixtures' folder
      file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/users.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
    end
  end

  # Create a dummy users.xlsx file in 'spec/fixtures/files/users.xlsx' for this to work

  let(:user_import) { create(:user_import) }

  it "enqueues the job" do
    expect {
      ImportUsersJob.perform_later(user_import.id)
    }.to have_enqueued_job
  end

  it "creates new users from the spreadsheet" do
    # Mock the Roo spreadsheet parser
    spreadsheet_data = [
      [ "full_name", "email" ], # Header row
      [ "Job User 1", "job1@example.com" ],
      [ "Job User 2", "job2@example.com" ]
    ]

    # Mock the 'Down' gem download
    allow(Down).to receive(:download).and_return(Rails.root.join('spec/fixtures/files/users.xlsx'))

    # Mock the spreadsheet
    spreadsheet_mock = instance_double(Roo::Excelx)
    allow(Roo::Spreadsheet).to receive(:open).and_return(spreadsheet_mock)
    allow(spreadsheet_mock).to receive(:each_with_index).and_yield(spreadsheet_data[1], 1).and_yield(spreadsheet_data[2], 2)
    allow(spreadsheet_mock).to receive(:last_row).and_return(3)

    # Perform the job
    # We use perform_enqueued_jobs to run the job immediately
    expect {
      perform_enqueued_jobs { ImportUsersJob.perform_later(user_import.id) }
    }.to change(User, :count).by(2)

    expect(User.last.email).to eq("job2@example.com")
    expect(user_import.reload.status).to eq("completed")
  end

  it "logs errors for invalid users" do
    # ... (similar test, but yield invalid data) ...
  end
end
