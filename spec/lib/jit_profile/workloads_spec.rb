require "rails_helper"
require Rails.root.join("lib/jit_profile").to_s

RSpec.describe JitProfile::Workloads do
  subject(:workloads) { described_class.new }

  described_class::NAMES.each do |name|
    it "builds #{name} into a call that can repeat" do
      call = workloads.build(name)

      expect { 2.times { call.call } }.not_to raise_error
    end
  end

  it "serialises every user" do
    expect(JSON.parse(workloads.build("serialize_users").call).size).to eq(described_class::ROWS)
  end

  it "turns every spreadsheet row into user attributes" do
    attributes = workloads.build("import_rows").call

    expect(attributes.size).to eq(described_class::ROWS)
    expect(attributes.first).to include(full_name: "User 0", email_address: "user0@example.com")
  end

  it "reads every CSV row" do
    expect(workloads.build("parse_csv").call).to eq(described_class::ROWS)
  end

  it "renders the sign-up page" do
    expect(workloads.build("render_page").call).to eq(200)
  end

  it "rejects unknown workloads" do
    expect { workloads.build("nope") }.to raise_error(ArgumentError, /serialize_users/)
  end
end
