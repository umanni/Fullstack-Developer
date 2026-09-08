# Restart the server after changing this policy.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.font_src :self, :data
    policy.form_action :self
    policy.frame_ancestors :none
    policy.img_src :self, :data, :blob
    policy.object_src :none
    policy.script_src :self
    policy.style_src :self, :unsafe_inline

    if Rails.env.development?
      vite_http = "http://#{ViteRuby.config.host_with_port}"
      vite_ws = "ws://#{ViteRuby.config.host_with_port}"
      policy.connect_src :self, vite_http, vite_ws
      policy.script_src :self, vite_http, :unsafe_eval
      policy.style_src :self, vite_http, :unsafe_inline
    else
      policy.connect_src :self, "wss:"
    end
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_nonce_auto = true
end
