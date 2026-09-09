require "rails_helper"

RSpec.describe UserCounters do
  describe ".current" do
    it "counts everybody and splits them by role" do
      create_list(:user, 2)
      create(:user, :admin)

      counters = described_class.current

      expect(counters.total).to eq(3)
      expect(counters.admins).to eq(1)
      expect(counters.users).to eq(2)
    end

    it "reports zero for a role nobody holds" do
      create(:user)

      expect(described_class.current.admins).to be_zero
    end
  end

  describe "broadcasting" do
    def broadcasts_for(locale)
      ActionCable.server.pubsub.broadcasts(described_class.stream_for(locale))
    end

    it "broadcasts to every supported locale when a user is created" do
      expect { create(:user) }
        .to change { broadcasts_for("en").size }.by(1)
        .and change { broadcasts_for("pt-BR").size }.by(1)
        .and change { broadcasts_for("es").size }.by(1)
    end

    it "broadcasts when a user is deleted" do
      user = create(:user)

      expect { user.destroy! }.to change { broadcasts_for("en").size }.by(1)
    end

    it "broadcasts when a role changes" do
      user = create(:user)

      expect { user.update!(role: :admin) }.to change { broadcasts_for("en").size }.by(1)
    end

    it "stays quiet when a change cannot affect the counters" do
      user = create(:user)

      expect { user.update!(full_name: "Another Name") }
        .not_to(change { broadcasts_for("en").size })
    end

    it "can be suspended so a bulk operation broadcasts once instead of per row" do
      expect do
        described_class.suspend_broadcasts { create_list(:user, 3) }
      end.not_to(change { broadcasts_for("en").size })
    end
  end
end
