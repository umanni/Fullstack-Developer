require "capybara/rspec"
require "capybara/cuprite"

# Cuprite drives the Chromium installed in the development image over CDP.
# Both run inside the same container, so the test server is reachable on
# localhost and no host networking is involved.
#
# The flag list is mostly about startup time: left alone, Chromium spends
# several seconds on background networking (GCM registration, component
# updates) before it prints the DevTools websocket URL that Ferrum waits for,
# which is enough to trip the process timeout on a cold start.
CHROME_FLAGS = {
  "no-sandbox" => nil,
  "disable-dev-shm-usage" => nil,
  "disable-gpu" => nil,
  "disable-background-networking" => nil,
  "disable-background-timer-throttling" => nil,
  "disable-backgrounding-occluded-windows" => nil,
  "disable-breakpad" => nil,
  "disable-component-update" => nil,
  "disable-default-apps" => nil,
  "disable-extensions" => nil,
  "disable-renderer-backgrounding" => nil,
  "disable-sync" => nil,
  "disable-features" => "Translate,BackForwardCache,MediaRouter,OptimizationHints,AcceptCHFrame",
  "no-first-run" => nil,
  "mute-audio" => nil
}.freeze

# Rails' `driven_by :cuprite` registers the driver itself, discarding anything
# passed to Capybara.register_driver beforehand, and it mutates the options
# hash it is given. So the options are built fresh for each example rather than
# shared as a frozen constant.
def cuprite_options
  {
    browser_path: ENV.fetch("BROWSER_PATH", nil),
    browser_options: CHROME_FLAGS.dup,
    process_timeout: 60,
    timeout: 30,
    headless: true
  }
end

Capybara.default_driver = :rack_test
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }
Capybara.disable_animation = true

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :rack_test }

  config.before(:each, :js, type: :system) do
    driven_by :cuprite, screen_size: [1400, 1000], options: cuprite_options
  end
end
