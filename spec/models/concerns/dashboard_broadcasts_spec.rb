require "rails_helper"

RSpec.describe DashboardBroadcasts do
  it "is not suppressed by default" do
    expect(described_class).not_to be_suppressed
  end

  it "is suppressed inside the block and not after it" do
    inside = nil

    described_class.suppress { inside = described_class.suppressed? }

    expect(inside).to be(true)
    expect(described_class).not_to be_suppressed
  end

  it "returns the block's value" do
    expect(described_class.suppress { :done }).to eq(:done)
  end

  it "lifts suppression even when the block raises" do
    expect { described_class.suppress { raise "boom" } }.to raise_error("boom")

    expect(described_class).not_to be_suppressed
  end

  it "stays suppressed after a nested block finishes inside an outer one" do
    still_suppressed = nil

    described_class.suppress do
      described_class.suppress { nil }
      still_suppressed = described_class.suppressed?
    end

    expect(still_suppressed).to be(true)
    expect(described_class).not_to be_suppressed
  end

  it "does not reach other threads" do
    elsewhere = nil

    described_class.suppress { elsewhere = Thread.new { described_class.suppressed? }.value }

    expect(elsewhere).to be(false)
  end
end
