require "json"

module JitProfile
  # The in-app half of bin/jit-profile, run through `bin/rails runner`: measures each workload
  # under whichever JIT this process got, and writes the results as JSON for the driver.
  class Probe
    def self.run_from_env(env = ENV)
      new(
        workloads: env.fetch("JIT_PROFILE_WORKLOADS").split(","),
        warmup: Float(env.fetch("JIT_PROFILE_WARMUP")),
        duration: Float(env.fetch("JIT_PROFILE_DURATION"))
      ).run(env.fetch("JIT_PROFILE_OUTPUT"))
    end

    def initialize(workloads:, warmup:, duration:, factory: Workloads.new)
      @workloads = workloads
      @warmup = warmup
      @duration = duration
      @factory = factory
    end

    def run(output_path)
      results = {
        "ruby" => RUBY_DESCRIPTION,
        "rails_env" => Rails.env.to_s,
        "jit" => RubyJit.active,
        "workloads" => @workloads.to_h { |name| [ name, measure(name) ] }
      }
      File.write(output_path, JSON.pretty_generate(results))
      results
    end

    private

    def measure(name)
      callable = @factory.build(name)
      GC.start
      JitStats.reset

      Benchmark.measure(callable, warmup: @warmup, duration: @duration).merge("jit_stats" => JitStats.snapshot)
    end
  end
end
