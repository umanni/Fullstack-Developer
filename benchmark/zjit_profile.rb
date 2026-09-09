#!/usr/bin/env ruby
# Performance profiling leveraging Ruby 4's ZJIT compilation optimizations
# Usage: RUBYOPT="--zjit" ruby benchmark/zjit_profile.rb

require_relative "../config/environment"
require "benchmark/ips"

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)
  x.report("user creation") { User.create!(full_name: "ZJIT", email: "zjit#{rand(1000)}@example.com", password: "password123", password_confirmation: "password123") }
  x.compare!
end
