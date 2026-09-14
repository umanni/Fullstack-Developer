require "rails_helper"
require Rails.root.join("lib/jit_profile").to_s

RSpec.describe JitProfile::Driver do
  let(:io) { StringIO.new }
  let(:calls) { [] }
  let(:ips) { { "off" => 100.0, "yjit" => 150.0, "zjit" => 120.0 } }
  let(:runner) do
    lambda do |env, command|
      calls << { env:, command: }
      result = { "ruby" => RUBY_DESCRIPTION, "rails_env" => "production", "jit" => env["RUBY_JIT"],
                 "workloads" => { "render_page" => { "ips" => ips.fetch(env["RUBY_JIT"]), "jit_stats" => {} } } }
      File.write(env["JIT_PROFILE_OUTPUT"], JSON.generate(result))
    end
  end
  let(:driver) do
    described_class.new(root: Rails.root.to_s, workloads: %w[render_page], warmup: 1, duration: 2, runner:, io:)
  end

  it "runs a fresh bin/rails runner per JIT and writes the report" do
    Dir.mktmpdir do |dir|
      report = driver.run(dir)

      expect(calls.map { |call| call[:env]["RUBY_JIT"] }).to eq(%w[off yjit zjit zjit])
      expect(report.speedup("yjit", "render_page")).to eq(1.5)
      expect(File.read(File.join(dir, "report.md"))).to include("| render_page |")
      expect(JSON.parse(File.read(File.join(dir, "results.json"))).keys).to eq(described_class::RUNS.keys)
    end
  end

  it "adds the ZJIT stats flags to the diagnostics run only" do
    Dir.mktmpdir { |dir| driver.run(dir) }
    rubyopts = calls.map { |call| call[:env]["RUBYOPT"].to_s }

    expect(rubyopts.last).to include("--zjit-stats-quiet --zjit-disable")
    expect(rubyopts.first(3).grep(/--zjit/)).to be_empty
  end

  it "keeps SSR and logging out of the timings and tells the probe what to run" do
    Dir.mktmpdir { |dir| driver.run(dir) }

    expect(calls.first[:env]).to include(
      "INERTIA_SSR_ENABLED" => "false", "RAILS_LOG_LEVEL" => "warn",
      "JIT_PROFILE_WORKLOADS" => "render_page", "JIT_PROFILE_WARMUP" => "1", "JIT_PROFILE_DURATION" => "2"
    )
    expect(calls.first[:command]).to eq([ Rails.root.join("bin/rails").to_s, "runner", described_class::PROBE ])
  end

  it "rejects unknown workloads" do
    expect { described_class.new(root: "/", workloads: %w[nope], warmup: 0, duration: 0) }
      .to raise_error(ArgumentError, /nope/)
  end

  it "stops with the child's output when a run fails" do
    failing = described_class.new(root: Dir.pwd, workloads: [], warmup: 0, duration: 0)

    expect { failing.send(:run_process, {}, [ RbConfig.ruby, "-e", "warn 'boom'; exit 1" ]) }
      .to raise_error(RuntimeError, /boom/)
  end
end
