require "capybara/rspec"
require "capybara/cuprite"

# Cuprite talks to the Chromium installed in the development image over CDP.
# Both run inside the same container, so the test server is reachable on
# localhost and no host networking is involved.
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1400, 1000],
    browser_path: ENV.fetch("BROWSER_PATH", nil),
    browser_options: {
      "no-sandbox" => nil,
      "disable-dev-shm-usage" => nil,
      "disable-gpu" => nil
    },
    process_timeout: 30,
    timeout: 15,
    headless: true
  )
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }
Capybara.disable_animation = true

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :rack_test }
  config.before(:each, :js, type: :system) { driven_by :cuprite }
end
