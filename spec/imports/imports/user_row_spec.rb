require "rails_helper"

RSpec.describe Imports::UserRow, type: :model do
  def row(**attributes)
    described_class.new(full_name: "Grace Hopper", email_address: "grace@example.com", **attributes)
  end

  describe ".normalize_headers" do
    it "maps canonical names and their aliases onto attributes" do
      expect(described_class.normalize_headers(%w[full_name email role avatar_url]))
        .to eq(%i[full_name email_address role avatar_url])
    end

    it "accepts the Portuguese headers" do
      expect(described_class.normalize_headers(%w[nome perfil])).to eq(%i[full_name role])
    end

    it "ignores case, surrounding space and punctuation" do
      expect(described_class.normalize_headers([ " Full Name ", "E-mail", "AVATAR" ]))
        .to eq(%i[full_name email_address avatar_url])
    end

    it "sees past the byte-order mark Excel writes before the first header" do
      expect(described_class.normalize_headers([ "\uFEFFname" ])).to eq([ :full_name ])
    end

    it "keeps unknown and blank headers as nil so column positions still line up" do
      expect(described_class.normalize_headers([ "name", "department", nil, "email" ]))
        .to eq([ :full_name, nil, nil, :email_address ])
    end
  end

  describe ".from" do
    let(:headers) { %i[full_name email_address role] }

    it "pairs each value with the header in the same column" do
      user_row = described_class.from(headers, [ "Grace Hopper", "grace@example.com", "admin" ])

      expect(user_row).to have_attributes(full_name: "Grace Hopper", email_address: "grace@example.com", role: "admin")
    end

    it "drops columns whose header was not recognised" do
      user_row = described_class.from([ :full_name, nil, :email_address ],
                                      [ "Grace Hopper", "Engineering", "grace@example.com" ])

      expect(user_row).to have_attributes(full_name: "Grace Hopper", email_address: "grace@example.com")
    end

    it "falls back to member when the role cell is empty" do
      expect(described_class.from(headers, [ "Grace Hopper", "grace@example.com", nil ]).role).to eq("member")
    end

    it "falls back to member when the file has no role column" do
      user_row = described_class.from(%i[full_name email_address], [ "Grace Hopper", "grace@example.com" ])

      expect(user_row.role).to eq("member")
    end

    it "tolerates a row shorter than the header" do
      expect(described_class.from(headers, [ "Grace Hopper" ]))
        .to have_attributes(full_name: "Grace Hopper", email_address: nil, role: "member")
    end

    it "sanitizes every value" do
      expect(described_class.from([ :full_name ], [ "  =Grace   Hopper " ]).full_name).to eq("Grace Hopper")
    end
  end

  describe ".sanitize" do
    it "squishes whitespace" do
      expect(described_class.sanitize("  Grace \n  Hopper ")).to eq("Grace Hopper")
    end

    it "strips each leading character that would start a spreadsheet formula" do
      %w[=SUM(A1) +SUM(A1) -SUM(A1) @SUM(A1)].each do |cell|
        expect(described_class.sanitize(cell)).to eq("SUM(A1)")
      end
    end

    it "strips a whole run of them, not just the first" do
      expect(described_class.sanitize("=+-@cmd|' /C calc'!A0")).to eq("cmd|' /C calc'!A0")
    end

    it "leaves those characters alone past the start of the value" do
      expect(described_class.sanitize("Mary-Jane O'Neil")).to eq("Mary-Jane O'Neil")
      expect(described_class.sanitize("grace+navy@example.com")).to eq("grace+navy@example.com")
    end

    it "turns spreadsheet numbers into text" do
      expect(described_class.sanitize(1.5)).to eq("1.5")
    end
  end

  describe "validations" do
    subject(:user_row) { row }

    let(:role_message) { "must be admin or member" }

    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_length_of(:full_name).is_at_least(2).is_at_most(120) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to allow_value("grace.hopper+navy@example.com").for(:email_address) }
    it { is_expected.not_to allow_value("grace@", "not an email").for(:email_address) }

    it { is_expected.to validate_inclusion_of(:role).in_array(%w[member admin]).with_message(role_message) }

    it { is_expected.to allow_value(nil, "", "https://cdn.example.com/grace.png").for(:avatar_url) }
    it { is_expected.not_to allow_value("http://cdn.example.com/grace.png", "javascript:alert(1)").for(:avatar_url) }
  end

  describe "#normalized_email" do
    it "trims and lowercases" do
      expect(row(email_address: "  Grace@Example.COM ").normalized_email).to eq("grace@example.com")
    end

    it "is an empty string when there is no email" do
      expect(row(email_address: nil).normalized_email).to eq("")
    end
  end

  describe "#to_user_attributes" do
    it "is enough to create a User" do
      attributes = row(email_address: "Grace@Example.com", role: "admin").to_user_attributes

      expect(User.create!(attributes))
        .to have_attributes(full_name: "Grace Hopper", email_address: "grace@example.com", role: "admin")
    end

    it "turns a blank avatar URL into nil" do
      expect(row(avatar_url: "").to_user_attributes[:avatar_url]).to be_nil
    end

    it "generates a different 24-character password each time" do
      user_row = row
      first, second = 2.times.map { user_row.to_user_attributes[:password] }

      expect(first.length).to eq(24)
      expect(first).not_to eq(second)
    end
  end
end
