require "rails_helper"

RSpec.describe ApplicationCable::Connection do
  it "identifies the user behind a valid session cookie" do
    user = create(:user)
    session = user.sessions.create!(user_agent: "rspec", ip_address: "127.0.0.1")
    cookies.signed[:session_id] = session.id

    connect

    expect(connection.current_user).to eq(user)
  end

  it "refuses a connection with no session at all" do
    expect { connect }.to have_rejected_connection
  end

  it "refuses a connection whose session no longer exists" do
    cookies.signed[:session_id] = "00000000-0000-0000-0000-000000000000"

    expect { connect }.to have_rejected_connection
  end
end
