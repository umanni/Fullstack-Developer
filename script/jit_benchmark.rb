# Renders a partial under YJIT and ZJIT. Rails turns YJIT on by default, so there is no
# plain-interpreter column without disabling it.
#
#   docker compose exec -e RUBYOPT=--yjit web bin/rails runner script/jit_benchmark.rb
#   docker compose exec -e RUBYOPT=--zjit web bin/rails runner script/jit_benchmark.rb
#
# Against the production image instead, prefix with `db:prepare` and pass a master key
# that image can read.
#
# No benchmark gem: it stopped being a default gem in Ruby 4, and a monotonic clock
# is all this needs.

ITERATIONS = Integer(ENV.fetch("ITERATIONS", 20_000))
WARMUP = Integer(ENV.fetch("WARMUP", 5_000))

users = Array.new(50) do |index|
  User.new(id: index + 1, full_name: "Benchmark Person #{index}", email: "bench#{index}@umanni.test",
           role: index.even? ? "admin" : "user", created_at: Time.current)
end

def jit_name
  return "ZJIT" if defined?(RubyVM::ZJIT) && RubyVM::ZJIT.enabled?
  return "YJIT" if defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?

  "interpreter"
end

WARMUP.times { |i| ApplicationController.render(partial: "admin/users/user", locals: { user: users[i % 50] }) }

started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
ITERATIONS.times { |i| ApplicationController.render(partial: "admin/users/user", locals: { user: users[i % 50] }) }
elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

puts format("%-12s %6.2f s for %d renders (%.3f ms each, %d warmup)",
            jit_name, elapsed, ITERATIONS, elapsed * 1000 / ITERATIONS, WARMUP)
