module JitProfile
  # Formats the driver's results as Markdown: throughput per JIT with speedups over the
  # interpreter, then the ZJIT diagnostics from the --zjit-stats pass.
  class Report
    TIMED = { "interpreter" => "Interpreter", "yjit" => "YJIT", "zjit" => "ZJIT" }.freeze

    attr_reader :results

    def initialize(results)
      @results = results
    end

    def ips(run, workload) = results.dig(run, "workloads", workload, "ips")

    def speedup(run, workload)
      baseline = ips("interpreter", workload)
      value = ips(run, workload)
      (value / baseline).round(2) if value && baseline&.positive?
    end

    def to_markdown
      [ environment, *warnings, throughput, diagnostics ].compact.join("\n\n") + "\n"
    end

    private

    def workloads = results.values.flat_map { |run| run.fetch("workloads", {}).keys }.uniq

    def environment
      sample = results.values.first || {}
      "Ruby: `#{sample["ruby"]}`  \nRails environment: `#{sample["rails_env"]}`"
    end

    def warnings
      results.filter_map do |name, run|
        next if run["expected_jit"].nil? || run["jit"] == run["expected_jit"]

        "> **Warning:** the #{name} run asked for #{run["expected_jit"]} but ran with #{run["jit"]}, " \
          "so its numbers don't measure that JIT."
      end
    end

    def throughput
      rows = workloads.map do |name|
        cells = TIMED.keys.map { |run| number(ips(run, name)) }
        cells += %w[yjit zjit].map { |run| multiplier(speedup(run, name)) }
        "| #{name} | #{cells.join(" | ")} |"
      end

      [
        "### Throughput (iterations per second, higher is better)",
        "",
        "| Workload | #{TIMED.values.join(" | ")} | YJIT vs interpreter | ZJIT vs interpreter |",
        "|---|--:|--:|--:|--:|--:|",
        *rows
      ].join("\n")
    end

    def diagnostics
      runs = results.dig("zjit_stats", "workloads")
      return unless runs

      rows = runs.map do |name, data|
        stats = data.fetch("jit_stats", {})
        cells = [ number(stats["compiled_iseqs"]), number(stats["compile_ms"]), number(stats["side_exits"]),
                  percent(stats["dynamic_send_ratio"]), counters(stats["top_exits"]) ]
        "| #{name} | #{cells.join(" | ")} |"
      end

      [
        "### ZJIT diagnostics (--zjit-stats pass, untimed)",
        "",
        "| Workload | Compiled methods | Compile time (ms) | Side exits | Dynamic sends | Top side exits |",
        "|---|--:|--:|--:|--:|---|",
        *rows
      ].join("\n")
    end

    def number(value)
      return "n/a" if value.nil?

      integer, fraction = value.round(1).to_s.split(".")
      integer = integer.reverse.scan(/\d{1,3}/).join(",").reverse
      fraction.nil? || fraction == "0" ? integer : "#{integer}.#{fraction}"
    end

    def multiplier(value) = value.nil? ? "n/a" : "#{format("%.2f", value)}×"

    def percent(value) = value.nil? ? "n/a" : "#{number(value * 100)}%"

    def counters(counts)
      return "none" if counts.nil? || counts.empty?

      counts.map { |name, count| "#{name} #{number(count)}" }.join(", ")
    end
  end
end
