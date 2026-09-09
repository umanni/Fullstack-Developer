# Performance profiling leveraging Ruby 4 ZJIT
# Usage: RUBYOPT="--zjit" ruby benchmark/zjit_profile.rb
require "benchmark/ips"
Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)
  x.report("user creation") { User.create!(full_name: "ZJIT", email: "zjit#{rand(1000)}@example.com", password: "password123", password_confirmation: "password123") }
end
