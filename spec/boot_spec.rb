require "rails_helper"

RSpec.describe "Application boot" do
  it "loads the Rails environment without raising" do
    expect(Rails.application).to be_initialized
  end

  it "runs migrations with SQLite in WAL journal mode" do
    result = ActiveRecord::Base.lease_connection.execute("PRAGMA journal_mode").first["journal_mode"]

    expect(result).to eq("wal")
  end

  it "loads the required testing and infrastructure gems" do
    %w[FactoryBot Faker Shoulda::Matchers Capybara SolidQueue SolidCache SolidCable].each do |const_name|
      expect(const_name.safe_constantize).not_to be_nil, "expected #{const_name} to be loaded"
    end
  end

  it "uses the ActiveJob test adapter in the test environment" do
    expect(ActiveJob::Base.queue_adapter).to be_a(ActiveJob::QueueAdapters::TestAdapter)
  end
end
