require "rails_helper"

RSpec.describe ImportChannel, type: :channel do
  let(:import) { create(:import) }

  it "subscribes an admin to that import's stream" do
    stub_connection current_user: create(:user, :admin)

    subscribe id: import.id

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from(Imports::ProgressBroadcaster.stream_for(import))
  end

  it "does not stream any other import to that subscriber" do
    other = create(:import)
    stub_connection current_user: create(:user, :admin)

    subscribe id: import.id

    expect(subscription).not_to have_stream_from(Imports::ProgressBroadcaster.stream_for(other))
  end

  it "turns a member away, even from an import in their own name" do
    member = create(:user)
    stub_connection current_user: member

    subscribe id: create(:import, user: member).id

    expect(subscription).to be_rejected
  end

  it "turns away a connection with no identified user" do
    stub_connection current_user: nil

    subscribe id: import.id

    expect(subscription).to be_rejected
  end

  it "rejects an id that matches no import" do
    stub_connection current_user: create(:user, :admin)

    subscribe id: 0

    expect(subscription).to be_rejected
  end

  it "rejects a subscription that names no import" do
    stub_connection current_user: create(:user, :admin)

    subscribe

    expect(subscription).to be_rejected
  end
end
