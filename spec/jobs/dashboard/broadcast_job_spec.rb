require "rails_helper"

RSpec.describe Dashboard::BroadcastJob do
  it "runs on the default queue" do
    expect(described_class.new.queue_name).to eq("default")
  end

  it "broadcasts the stats.changed payload when performed" do
    expect { described_class.perform_now }
      .to have_broadcasted_to(Dashboard::Broadcaster::STREAM)
      .with(type: "stats.changed")
  end

  it "drops the cached stats before broadcasting", :cache do
    Dashboard::Stats.current

    described_class.perform_now

    expect(Rails.cache.read(Dashboard::Stats::CACHE_KEY)).to be_nil
  end
end
