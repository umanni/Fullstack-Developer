require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(username: "testuser", password: "senha123546", role: "user")
    expect(user).to be_valid
  end

  it "is invalid without username" do
    user = User.new(password: "senha123", role: "user")
    expect(user).not_to be_valid
  end

  it "raises error with wrong role format" do
    expect {
      User.new(username: "John Doe", password: "senhhaaaaa", role: "ceo")
    }.to raise_error(ArgumentError, /is not a valid role/)
  end
end
