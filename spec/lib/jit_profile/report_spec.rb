require "rails_helper"
require Rails.root.join("lib/jit_profile").to_s

RSpec.describe JitProfile::Report do
  subject(:report) { described_class.new(results) }

  let(:results) do
    {
      "interpreter" => probe_result("off", 1000.0),
      "yjit" => probe_result("yjit", 2500.0),
      "zjit" => probe_result("zjit", 1500.0),
      "zjit_stats" => probe_result("zjit", 900.0,
                                   "compiled_iseqs" => 42, "compile_ms" => 12.5, "side_exits" => 1234,
                                   "dynamic_send_ratio" => 0.125,
                                   "top_exits" => { "guard_type_failure" => 1000, "interrupt" => 234 })
    }
  end

  def probe_result(jit, ips, stats = {})
    { "ruby" => "ruby 4.0.6 +PRISM", "rails_env" => "production", "jit" => jit, "expected_jit" => jit,
      "workloads" => { "parse_csv" => { "ips" => ips, "jit_stats" => stats } } }
  end

  it "compares each JIT with the interpreter" do
    expect(report.speedup("yjit", "parse_csv")).to eq(2.5)
    expect(report.speedup("zjit", "parse_csv")).to eq(1.5)
  end

  it "renders throughput as a Markdown table" do
    expect(report.to_markdown).to include("| parse_csv | 1,000 | 2,500 | 1,500 | 2.50× | 1.50× |")
  end

  it "renders the ZJIT diagnostics from the stats pass" do
    expect(report.to_markdown)
      .to include("| parse_csv | 42 | 12.5 | 1,234 | 12.5% | guard_type_failure 1,000, interrupt 234 |")
  end

  it "flags a run that didn't get the JIT it asked for" do
    results["zjit"]["jit"] = "off"

    expect(report.to_markdown).to include("the zjit run asked for zjit but ran with off")
  end

  it "shows n/a when there is nothing to compare with" do
    results["interpreter"]["workloads"]["parse_csv"]["ips"] = nil
    results.delete("zjit_stats")

    expect(report.speedup("yjit", "parse_csv")).to be_nil
    expect(report.to_markdown).to include("| parse_csv | n/a | 2,500 | 1,500 | n/a | n/a |")
    expect(report.to_markdown).not_to include("ZJIT diagnostics")
  end
end
