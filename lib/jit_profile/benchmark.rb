module JitProfile
  # Calls a workload in a tight loop: untimed for `warmup` seconds, long enough for a JIT to
  # profile and compile it, then for `duration` seconds that count.
  module Benchmark
    class << self
      def measure(callable, warmup:, duration:)
        run_for(callable, warmup)
        iterations, elapsed = run_for(callable, duration)

        { "iterations" => iterations, "seconds" => elapsed.round(3), "ips" => (iterations / elapsed).round(2) }
      end

      private

      def run_for(callable, seconds)
        started = now
        iterations = 0

        loop do
          callable.call
          iterations += 1
          elapsed = now - started
          return [ iterations, elapsed ] if elapsed >= seconds
        end
      end

      def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
