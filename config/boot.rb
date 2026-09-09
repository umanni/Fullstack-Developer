ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
RubyVM::ZJIT.enable if defined?(RubyVM::ZJIT)
require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
