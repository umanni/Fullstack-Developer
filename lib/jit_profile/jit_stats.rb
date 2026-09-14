module JitProfile
  # What the running JIT reports about itself. The probe resets the counters before each
  # workload, so a snapshot covers that workload's warmup and timed run.
  #
  # With --zjit-stats, ZJIT also counts where compiled code gave control back to the
  # interpreter: side exits (a type or shape guard failed) and method calls it couldn't
  # specialise (send fallbacks). Those are where ZJIT loses time, so they come out ranked.
  module JitStats
    TOP = 5

    class << self
      def snapshot
        case RubyJit.active
        when "zjit" then zjit(RubyVM::ZJIT.stats, detailed: RubyVM::ZJIT.stats_enabled?)
        when "yjit" then yjit(RubyVM::YJIT.runtime_stats)
        else {}
        end
      end

      def reset
        case RubyJit.active
        when "zjit" then RubyVM::ZJIT.reset_stats!
        when "yjit" then RubyVM::YJIT.reset_stats!
        end
      end

      def zjit(stats, detailed:)
        summary = {
          "compiled_iseqs" => stats[:compiled_iseq_count],
          "failed_iseqs" => stats[:failed_iseq_count],
          "compile_ms" => milliseconds(stats[:compile_time_ns]),
          "code_bytes" => stats[:code_region_bytes],
          "memory_bytes" => stats[:total_mem_bytes]
        }

        if detailed
          summary.merge!(
            "side_exits" => stats[:side_exit_count],
            "dynamic_send_ratio" => ratio(stats[:dynamic_send_count], stats[:send_count]),
            "top_exits" => top(stats, "exit_"),
            "top_send_fallbacks" => top(stats, "send_fallback_")
          )
        end

        summary.compact
      end

      def yjit(stats)
        {
          "compiled_iseqs" => stats[:compiled_iseq_count],
          "code_bytes" => stats[:inline_code_size],
          "memory_bytes" => stats[:yjit_alloc_size],
          "side_exits" => stats[:side_exit_count],
          "ratio_in_yjit" => stats[:ratio_in_yjit]
        }.compact
      end

      private

      def milliseconds(nanoseconds) = nanoseconds && (nanoseconds / 1_000_000.0).round(2)

      def ratio(part, total)
        (part.to_f / total).round(4) if total.to_i.positive?
      end

      def top(stats, prefix)
        counts = stats.filter_map do |key, count|
          [ key.to_s.delete_prefix(prefix), count ] if key.to_s.start_with?(prefix) && count.to_i.positive?
        end
        counts.max_by(TOP, &:last).to_h
      end
    end
  end
end
