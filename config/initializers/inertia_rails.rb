# frozen_string_literal: true

InertiaRails.configure do |config|
  config.version = ViteRuby.digest
  config.encrypt_history = true
  config.always_include_errors_hash = true
  config.use_script_element_for_initial_page = true
  config.use_data_inertia_head_attribute = true

  # Server-side rendering. `bin/vite dev` renders through its /__inertia_ssr endpoint; everywhere
  # else the inertia_ssr Puma plugin (config/puma.rb) runs this bundle, built by assets:precompile.
  # Without either, pages fall back to rendering in the browser.
  config.ssr_enabled = ENV.fetch("INERTIA_SSR_ENABLED", (!Rails.env.test?).to_s) == "true"
  config.ssr_bundle = ViteRuby.config.ssr_output_dir.join("ssr.js").to_s
end
