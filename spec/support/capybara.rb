# frozen_string_literal: true

Capybara.register_driver :apparition do |app|
  options = {
    headless: true, skip_image_loading: false, window_size: [1366, 768],
    browser_options: [:disable_gpu, :no_sandbox, disable_features: 'VizDisplayCompositor']
  }
  Capybara::Apparition::Driver.new(app, options)
end

Capybara.register_driver :apparition_debug do |app|
  Capybara::Apparition::Driver.new(app, inspector: true)
end

Capybara.javascript_driver = :apparition
# Capybara.javascript_driver = :apparition_debug
