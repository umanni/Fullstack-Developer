# RUBY_JIT=yjit|zjit|off chooses the JIT (see lib/ruby_jit.rb). Initializers run before
# Rails' own :enable_yjit step, so config.yjit can still be overridden here.
require Rails.root.join("lib/ruby_jit").to_s

RubyJit.configure(Rails.application.config)

Rails.application.config.after_initialize do
  RubyJit.enable_zjit(logger: Rails.logger)
end
