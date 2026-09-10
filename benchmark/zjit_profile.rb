# Performance profiling leveraging Ruby 4 ZJIT
# Usage: RUBYOPT="--zjit" ruby benchmark/zjit_profile.rb
require_relative "../config/environment"
require "securerandom"
require "benchmark/ips"
Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)
  x.report("user creation") { User.create!(full_name: "ZJIT", email: "zjit-#{SecureRandom.uuid}@example.com", password: "Password123", password_confirmation: "Password123") }
end
