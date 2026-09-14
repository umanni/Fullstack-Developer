require "rails_helper"

RSpec.describe DashboardChannel, type: :channel do
  it "subscribes an admin to the dashboard stream" do
    stub_connection current_user: create(:user, :admin)

    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from(Dashboard::Broadcaster::STREAM)
  end

  it "turns a member away rather than leaking the counts" do
    stub_connection current_user: create(:user)

    subscribe

    expect(subscription).to be_rejected
  end

  it "turns away a connection with no identified user" do
    stub_connection current_user: nil

    subscribe

    expect(subscription).to be_rejected
  end

  it "delivers the broadcaster's payload to a subscribed admin" do
    stub_connection current_user: create(:user, :admin)
    subscribe

    expect { Dashboard::Broadcaster.broadcast }
      .to have_broadcasted_to(Dashboard::Broadcaster::STREAM)
      .with(type: "stats.changed")
  end
end
