require "rails_helper"

RSpec.describe Dashboard::Stats do
  describe "the computed figures" do
    it "counts every user regardless of role" do
      create_list(:user, 2)
      create(:user, :admin)

      expect(described_class.current[:total]).to eq(3)
    end

    it "breaks the count down by role" do
      create_list(:user, 2)
      create(:user, :admin)

      expect(described_class.current[:by_role]).to eq("member" => 2, "admin" => 1)
    end

    # `group(:role).count` omits roles nobody holds, so a dashboard reading
    # `by_role["admin"]` would get nil rather than 0 without the `index_with`.
    it "reports a role with no users as zero rather than omitting it" do
      create(:user)

      expect(described_class.current[:by_role]).to eq("member" => 1, "admin" => 0)
    end

    it "still answers with every role when there are no users at all" do
      expect(described_class.current).to include(total: 0, by_role: { "member" => 0, "admin" => 0 })
    end

    it "stamps the result with an iso8601 time" do
      generated_at = described_class.current[:generated_at]

      expect { Time.iso8601(generated_at) }.not_to raise_error
    end
  end

  # `:cache` swaps :null_store for a real store; see spec/support/cache_helpers.rb.
  describe "caching", :cache do
    # User's after_commit hook expires this cache on every create, which would
    # mask what these examples are checking: creating a user is the only way to
    # move the counts, so the invalidation has to be held back to see the cache
    # do its job. Broadcaster's own spec covers the hook firing for real.
    before { allow(Dashboard::Broadcaster).to receive(:call) }

    it "serves a cached copy rather than recounting" do
      create(:user)
      described_class.current

      create(:user, :admin)

      expect(described_class.current[:total]).to eq(1)
    end

    # Advancing the clock is what gives this teeth: `generated_at` is only
    # second-precise, so two back-to-back calls match whether or not anything
    # was cached. Two seconds in, still inside the TTL, a recompute would show.
    it "hands back the same generated_at while the entry is warm" do
      first = described_class.current[:generated_at]

      travel(2.seconds) do
        expect(described_class.current[:generated_at]).to eq(first)
      end
    end

    it "recounts once the entry has expired" do
      create(:user)
      described_class.current

      create(:user, :admin)
      travel(described_class::CACHE_TTL + 1.second) do
        expect(described_class.current[:total]).to eq(2)
      end
    end

    describe ".expire" do
      it "drops the entry so the next read recounts" do
        create(:user)
        described_class.current

        create(:user, :admin)
        described_class.expire

        expect(described_class.current[:total]).to eq(2)
      end

      it "is harmless when nothing has been cached yet" do
        expect { described_class.expire }.not_to raise_error
      end
    end
  end
end
