require "fileutils"
require "json"
require "open3"
require "tmpdir"

module JitProfile
  # Runs the probe once per JIT, each in a fresh `bin/rails runner` process, because a process
  # can only ever run one JIT. ZJIT gets an extra, untimed pass with --zjit-stats: the counters
  # slow compiled code down, so they would skew the timed run.
  class Driver
    RUNS = {
      "interpreter" => { jit: "off" },
      "yjit" => { jit: "yjit" },
      "zjit" => { jit: "zjit" },
      # --zjit-disable leaves enabling ZJIT to config/initializers/ruby_jit.rb, after boot, as in the timed run.
      "zjit_stats" => { jit: "zjit", flags: "--zjit-stats-quiet --zjit-disable" }
    }.freeze
    PROBE = 'require Rails.root.join("lib/jit_profile").to_s; JitProfile::Probe.run_from_env'

    def initialize(root:, workloads:, warmup:, duration:, runner: nil, io: $stdout)
      unknown = workloads - Workloads::NAMES
      raise ArgumentError, "Unknown workloads: #{unknown.join(", ")}" if unknown.any?

      @root = root
      @workloads = workloads
      @warmup = warmup
      @duration = duration
      @runner = runner || method(:run_process)
      @io = io
    end

    def run(report_dir)
      results = RUNS.to_h { |name, run| [ name, probe(name, run) ] }
      report = Report.new(results)

      FileUtils.mkdir_p(report_dir)
      File.write(File.join(report_dir, "results.json"), JSON.pretty_generate(results))
      File.write(File.join(report_dir, "report.md"), report.to_markdown)
      @io.puts report.to_markdown
      report
    end

    private

    def probe(name, run)
      @io.puts "==> #{name}"

      Dir.mktmpdir do |dir|
        output = File.join(dir, "#{name}.json")
        @runner.call(child_env(run, output), [ File.join(@root, "bin/rails"), "runner", PROBE ])
        JSON.parse(File.read(output)).merge("expected_jit" => run[:jit])
      end
    end

    def child_env(run, output)
      rubyopt = [ ENV["RUBYOPT"], run[:flags] ].compact.join(" ")

      {
        "RUBY_JIT" => run[:jit],
        "RUBYOPT" => (rubyopt unless rubyopt.empty?),
        # Measure Ruby, not a round trip to the Node SSR server or log writes.
        "INERTIA_SSR_ENABLED" => "false",
        "RAILS_LOG_LEVEL" => "warn",
        "JIT_PROFILE_WORKLOADS" => @workloads.join(","),
        "JIT_PROFILE_WARMUP" => @warmup.to_s,
        "JIT_PROFILE_DURATION" => @duration.to_s,
        "JIT_PROFILE_OUTPUT" => output
      }
    end

    def run_process(env, command)
      output, status = Open3.capture2e(env, *command, chdir: @root)
      raise "#{command.first(2).join(" ")} failed (#{status}):\n#{output}" unless status.success?
    end
  end
end
