require "rails_helper"

RSpec.describe AdminStreamChannel do
  def subscribe_to_counters(locale = :en)
    subscribe(signed_stream_name: Turbo::StreamsChannel.signed_stream_name(UserCounters.stream_for(locale)))
  end

  it "accepts an administrator" do
    stub_connection current_user: create(:user, :admin)

    subscribe_to_counters

    expect(subscription).to be_confirmed
  end

  it "rejects a signed-in user who is not an administrator" do
    stub_connection current_user: create(:user)

    subscribe_to_counters

    expect(subscription).to be_rejected
  end

  it "rejects a connection with nobody behind it" do
    stub_connection current_user: nil

    subscribe_to_counters

    expect(subscription).to be_rejected
  end
end
