require "rails_helper"
require Rails.root.join("lib/jit_profile").to_s

RSpec.describe JitProfile::JitStats do
  let(:zjit_stats) do
    {
      compiled_iseq_count: 12, failed_iseq_count: 0, compile_time_ns: 3_500_000, code_region_bytes: 8192,
      total_mem_bytes: 20_000, side_exit_count: 40, dynamic_send_count: 25, send_count: 100,
      exit_guard_type_failure: 30, exit_interrupt: 10, exit_stackoverflow: 0,
      send_fallback_send_megamorphic: 20, send_fallback_send_no_profiles: 5
    }
  end

  describe ".zjit" do
    it "summarises compilation when stats weren't enabled" do
      expect(described_class.zjit(zjit_stats, detailed: false)).to eq(
        "compiled_iseqs" => 12, "failed_iseqs" => 0, "compile_ms" => 3.5, "code_bytes" => 8192, "memory_bytes" => 20_000
      )
    end

    it "ranks side exits and send fallbacks under --zjit-stats" do
      summary = described_class.zjit(zjit_stats, detailed: true)

      expect(summary).to include("side_exits" => 40, "dynamic_send_ratio" => 0.25)
      expect(summary["top_exits"]).to eq("guard_type_failure" => 30, "interrupt" => 10)
      expect(summary["top_send_fallbacks"].keys).to eq(%w[send_megamorphic send_no_profiles])
    end

    it "leaves out ratios it can't compute" do
      summary = described_class.zjit({ send_count: 0 }, detailed: true)

      expect(summary).not_to have_key("dynamic_send_ratio")
    end
  end

  describe ".yjit" do
    it "keeps the counters YJIT reports" do
      stats = { compiled_iseq_count: 7, inline_code_size: 4096, yjit_alloc_size: 9000 }

      expect(described_class.yjit(stats)).to eq("compiled_iseqs" => 7, "code_bytes" => 4096, "memory_bytes" => 9000)
    end
  end

  describe ".snapshot and .reset" do
    it "have nothing to report under the interpreter" do
      allow(RubyJit).to receive(:active).and_return("off")

      expect(described_class.snapshot).to eq({})
      expect(described_class.reset).to be_nil
    end

    it "read and reset ZJIT's counters when ZJIT runs" do
      allow(RubyJit).to receive(:active).and_return("zjit")
      zjit = class_double("RubyVM::ZJIT", stats: zjit_stats, stats_enabled?: false, reset_stats!: nil) # rubocop:disable RSpec/VerifiedDoubleReference
             .as_stubbed_const

      expect(described_class.snapshot).to include("compiled_iseqs" => 12)
      described_class.reset
      expect(zjit).to have_received(:reset_stats!)
    end

    it "read and reset YJIT's counters when YJIT runs" do
      allow(RubyJit).to receive(:active).and_return("yjit")
      yjit = class_double("RubyVM::YJIT", runtime_stats: { compiled_iseq_count: 3 }, reset_stats!: nil) # rubocop:disable RSpec/VerifiedDoubleReference
             .as_stubbed_const

      expect(described_class.snapshot).to eq("compiled_iseqs" => 3)
      described_class.reset
      expect(yjit).to have_received(:reset_stats!)
    end
  end
end
