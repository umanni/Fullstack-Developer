# Tooling behind bin/jit-profile, which compares the interpreter, YJIT and ZJIT on this app's
# hot paths. config/application.rb keeps it out of autoloading: the driver runs without
# booting Rails, and the probe is required on demand inside `bin/rails runner`.
require_relative "ruby_jit"
require_relative "jit_profile/benchmark"
require_relative "jit_profile/jit_stats"
require_relative "jit_profile/workloads"
require_relative "jit_profile/probe"
require_relative "jit_profile/report"
require_relative "jit_profile/driver"
