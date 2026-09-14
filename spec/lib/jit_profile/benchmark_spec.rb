require "rails_helper"
require Rails.root.join("lib/jit_profile").to_s

RSpec.describe JitProfile::Benchmark do
  it "warms up untimed, then reports iterations per second over the timed run" do
    calls = 0
    result = described_class.measure(-> { calls += 1 }, warmup: 0.01, duration: 0.02)

    expect(result["iterations"]).to be_positive
    expect(calls).to be > result["iterations"]
    expect(result["seconds"]).to be >= 0.02
    expect(result["ips"]).to be_positive
  end

  it "always runs a workload at least once" do
    result = described_class.measure(-> { }, warmup: 0, duration: 0)

    expect(result["iterations"]).to eq(1)
  end
end
