require "rails_helper"

# Pins the signed-out branch of `auth.user` on ApplicationController itself, so it
# holds regardless of which real pages happen to allow unauthenticated access.
RSpec.describe ApplicationController, type: :controller do
  controller(described_class) do
    allow_unauthenticated_access

    def index = render(inertia: "home/index")
  end

  before { routes.draw { get "index" => "anonymous#index" } }

  it "shares a nil user rather than dropping the key when nobody is signed in" do
    get :index

    expect(inertia.props.deep_symbolize_keys[:auth]).to eq(user: nil)
  end

  it "still shares the flash keys when nobody is signed in" do
    get :index

    expect(inertia.props.deep_symbolize_keys[:flash]).to eq(notice: nil, alert: nil)
  end
end
