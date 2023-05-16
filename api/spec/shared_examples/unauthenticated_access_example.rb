shared_examples "unauthenticated access" do
  it "returns unauthorized access" do
    expect(response).to have_http_status(:unauthorized)
  end
end