# Measures the CPU-bound part of the application -- parsing and normalising a
# spreadsheet -- so a claim about ZJIT can be checked rather than repeated.
#
#   bin/rails runner script/benchmarks/zjit.rb              # interpreter
#   RUBYOPT="--zjit" bin/rails runner script/benchmarks/zjit.rb
#
# Nothing is written to the database: what is timed is the parser, not
# PostgreSQL. A request that spends most of its time waiting on the database
# has far less to gain, which is the point of measuring this way.
require "csv"

ROWS = Integer(ENV.fetch("ROWS", 20_000))
RUNS = Integer(ENV.fetch("RUNS", 5))

path = Rails.root.join("tmp/zjit-benchmark.csv")
CSV.open(path, "w") do |csv|
  csv << %w[full_name email avatar_url role]
  ROWS.times { |i| csv << ["  Person #{i}  ", "PERSON#{i}@Example.com ", nil, i.even? ? "user" : "admin"] }
end

parser = UserImportParser.new(path: path.to_s, format: :csv)
stub = UserImportParser.const_get(:MAX_ROWS)
UserImportParser.send(:remove_const, :MAX_ROWS)
UserImportParser.const_set(:MAX_ROWS, ROWS + 1)

def measure
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  yield
  Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
end

times = Array.new(RUNS) do
  measure do
    rows = 0
    parser.each_row { |_number, attributes| rows += attributes[:full_name].length }
    rows
  end
end

UserImportParser.send(:remove_const, :MAX_ROWS)
UserImportParser.const_set(:MAX_ROWS, stub)
path.delete

jit = if defined?(RubyVM::ZJIT) && RubyVM::ZJIT.enabled?
        "ZJIT"
      elsif defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?
        "YJIT"
      else
        "interpreter"
      end

puts format("ruby %<version>s, %<jit>s, %<rows>d rows, %<runs>d runs",
            version: RUBY_VERSION, jit: jit, rows: ROWS, runs: RUNS)
puts format("  best   %<best>.3f s", best: times.min)
puts format("  median %<median>.3f s", median: times.sort[times.size / 2])
