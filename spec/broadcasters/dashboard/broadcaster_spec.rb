require "rails_helper"

# Every example needs a real cache store: the leading/trailing claims are
# `unless_exist` writes, and :null_store reports every write as a fresh claim,
# which would make the debounce look like it works while doing nothing.
RSpec.describe Dashboard::Broadcaster, :cache do
  describe ".call" do
    # Asserting on the cache entry rather than on a recount: creating a user
    # would expire the entry through User's own after_commit hook, so a count
    # that came out fresh would prove nothing about this call.
    it "drops the cached stats so the next read recounts" do
      Dashboard::Stats.current

      described_class.call

      expect(Rails.cache.read(Dashboard::Stats::CACHE_KEY)).to be_nil
    end

    it "broadcasts straight away on the leading edge" do
      expect { described_class.call }
        .to have_broadcasted_to(described_class::STREAM)
        .with(type: "stats.changed")
    end

    it "does not enqueue a trailing job for the leading call" do
      expect { described_class.call }.not_to have_enqueued_job(Dashboard::BroadcastJob)
    end

    context "when a second change lands inside the window" do
      before { described_class.call }

      it "does not broadcast again immediately" do
        expect { described_class.call }.not_to have_broadcasted_to(described_class::STREAM)
      end

      it "schedules the trailing broadcast instead" do
        expect { described_class.call }
          .to have_enqueued_job(Dashboard::BroadcastJob)
          .at(a_value_within(1.second).of(described_class::WINDOW.from_now))
      end

      # The point of the trailing key: a burst of changes collapses into one
      # scheduled broadcast rather than one per change.
      it "schedules only one trailing job however many changes arrive" do
        expect { 5.times { described_class.call } }
          .to have_enqueued_job(Dashboard::BroadcastJob).exactly(:once)
      end
    end

    it "broadcasts on the leading edge again once the window has passed" do
      described_class.call

      travel(described_class::WINDOW + 1.second) do
        expect { described_class.call }.to have_broadcasted_to(described_class::STREAM)
      end
    end
  end

  describe ".broadcast" do
    it "publishes the stats.changed payload on the dashboard stream" do
      expect { described_class.broadcast }
        .to have_broadcasted_to(described_class::STREAM)
        .with(type: "stats.changed")
    end

    it "does not claim the window, so it can be called by the trailing job" do
      described_class.broadcast

      expect { described_class.call }.to have_broadcasted_to(described_class::STREAM)
    end
  end
end
