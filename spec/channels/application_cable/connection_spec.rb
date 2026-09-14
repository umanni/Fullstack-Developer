require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  it "identifies the user behind a signed session cookie" do
    session = create(:session)
    cookies.signed[:session_id] = session.id

    connect "/cable"

    expect(connection.current_user).to eq(session.user)
  end

  it "rejects a connection without a session cookie" do
    expect { connect "/cable" }.to have_rejected_connection
  end

  it "rejects a session cookie that no longer resolves" do
    session = create(:session)
    cookies.signed[:session_id] = session.id
    session.destroy

    expect { connect "/cable" }.to have_rejected_connection
  end

  it "rejects an unsigned session cookie" do
    cookies[:session_id] = create(:session).id

    expect { connect "/cable" }.to have_rejected_connection
  end
end
