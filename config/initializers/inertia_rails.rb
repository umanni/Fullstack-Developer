# frozen_string_literal: true

InertiaRails.configure do |config|
  config.version = ViteRuby.digest
  config.encrypt_history = true
  config.always_include_errors_hash = true
  config.use_script_element_for_initial_page = true
  config.use_data_inertia_head_attribute = true

  # Server-side rendering via the Node bundle at public/vite-ssr/ssr.js,
  # booted automatically by the Puma inertia_ssr plugin. Enabled in
  # production; opt in elsewhere with INERTIA_SSR=1.
  config.ssr_enabled = Rails.env.production? || ENV["INERTIA_SSR"] == "1"
  config.ssr_url = "http://localhost:13714"
  config.ssr_bundle = Rails.root.join("public/vite-ssr/ssr.js").to_s
end
