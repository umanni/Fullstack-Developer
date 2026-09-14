require "rails_helper"
require Rails.root.join("lib/jit_profile").to_s

RSpec.describe JitProfile::Probe do
  it "measures each workload and writes the results as JSON" do
    factory = instance_double(JitProfile::Workloads)
    allow(factory).to receive(:build).with("noop").and_return(-> { })

    Dir.mktmpdir do |dir|
      path = File.join(dir, "results.json")
      described_class.new(workloads: %w[noop], warmup: 0, duration: 0.01, factory:).run(path)
      results = JSON.parse(File.read(path))

      expect(results).to include("jit" => RubyJit.active, "rails_env" => "test", "ruby" => RUBY_DESCRIPTION)
      expect(results.dig("workloads", "noop", "ips")).to be_positive
      expect(results.dig("workloads", "noop")).to have_key("jit_stats")
    end
  end

  it "reads its settings from the environment the driver sets" do
    probe = instance_double(described_class, run: {})
    allow(described_class).to receive(:new).and_return(probe)

    described_class.run_from_env(
      "JIT_PROFILE_WORKLOADS" => "parse_csv,render_page", "JIT_PROFILE_WARMUP" => "1.5",
      "JIT_PROFILE_DURATION" => "3", "JIT_PROFILE_OUTPUT" => "/tmp/results.json"
    )

    expect(described_class).to have_received(:new)
      .with(workloads: %w[parse_csv render_page], warmup: 1.5, duration: 3.0)
    expect(probe).to have_received(:run).with("/tmp/results.json")
  end
end
