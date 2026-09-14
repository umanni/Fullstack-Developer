require "rails_helper"

RSpec.describe Imports::ProgressBroadcaster do
  let!(:import) { create(:import) }

  describe ".stream_for" do
    it "names one stream per import" do
      expect(described_class.stream_for(import)).to eq("import:#{import.id}")
    end
  end

  describe ".call" do
    it "tells that import's subscribers it changed" do
      expect { described_class.call(import) }
        .to have_broadcasted_to("import:#{import.id}")
        .with(type: "import.changed", id: import.id)
    end

    it "leaves other imports' streams quiet" do
      other = create(:import)

      expect { described_class.call(import) }.not_to have_broadcasted_to("import:#{other.id}")
    end
  end
end
