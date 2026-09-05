require "rails_helper"

RSpec.describe AvatarDownloadJob, type: :job do
  let(:user) { create(:user) }

  it "attaches the fetched image to the user's avatar" do
    fetched = AvatarFetcher::Result.new(io: StringIO.new("bytes"), content_type: "image/png", filename: "avatar.png")
    allow(AvatarFetcher).to receive(:new).with("http://example.com/avatar.png").and_return(instance_double(AvatarFetcher, fetch: fetched))

    described_class.perform_now(user.id, "http://example.com/avatar.png")
    user.reload

    expect(user.avatar).to be_attached
    expect(user.avatar.content_type).to eq("image/png")
  end

  it "does nothing when the user no longer exists" do
    expect {
      described_class.perform_now(0, "http://example.com/avatar.png")
    }.not_to raise_error
  end

  it "logs and swallows fetch failures instead of raising" do
    failing_fetcher = instance_double(AvatarFetcher)
    allow(failing_fetcher).to receive(:fetch).and_raise(AvatarFetcher::FetchError, "boom")
    allow(AvatarFetcher).to receive(:new).with("http://example.com/avatar.png").and_return(failing_fetcher)

    expect(Rails.logger).to receive(:warn).with(/boom/)

    expect {
      described_class.perform_now(user.id, "http://example.com/avatar.png")
    }.not_to raise_error

    expect(user.avatar).not_to be_attached
  end
end
