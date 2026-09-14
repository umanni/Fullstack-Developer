# Picks the JIT compiler a Rails process runs with, from RUBY_JIT:
#
#   yjit  YJIT, Rails' default outside development and test
#   zjit  ZJIT, Ruby 4's method-based JIT
#   off   the interpreter only
#
# Unset keeps Rails' default. A process can run only one JIT, so choosing ZJIT also turns
# Rails' YJIT switch off. Both are enabled once the app has booted, so code that only runs
# while booting isn't compiled. PERFORMANCE.md has the measurements behind the default.
module RubyJit
  MODES = %w[yjit zjit off].freeze

  class << self
    def mode(env = ENV)
      value = env["RUBY_JIT"].to_s.strip.downcase
      return if value.empty?
      return value if MODES.include?(value)

      raise ArgumentError, "RUBY_JIT must be one of #{MODES.join(", ")}, got #{value.inspect}"
    end

    # Call from an initializer: Rails reads config.yjit later, in its :enable_yjit step.
    def configure(config, env = ENV)
      case mode(env)
      when "yjit" then config.yjit = true
      when "zjit", "off" then config.yjit = false
      end
    end

    def enable_zjit(logger:, env: ENV)
      return false unless mode(env) == "zjit"

      unless zjit_available?
        logger.warn "RUBY_JIT=zjit, but this Ruby was built without ZJIT (it needs rustc at build time). " \
                    "Running without a JIT."
        return false
      end

      return true if RubyVM::ZJIT.enabled? || RubyVM::ZJIT.enable

      logger.warn "RUBY_JIT=zjit, but another JIT is already running, so ZJIT stays off."
      false
    end

    # The JIT this process is running right now: "zjit", "yjit" or "off".
    def active
      if zjit_available? && RubyVM::ZJIT.enabled?
        "zjit"
      elsif defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?
        "yjit"
      else
        "off"
      end
    end

    def zjit_available? = RubyVM.const_defined?(:ZJIT)
  end
end
