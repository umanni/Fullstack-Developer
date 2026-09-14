# Everything is served from this origin, so there is no CDN to allow. `blob:` is for the
# object URLs the avatar preview creates.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :none
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :none
    policy.connect_src :self
    policy.font_src    :self
    policy.img_src     :self, :blob
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self
    # The import bar's width is a style attribute, and nonces do not apply to attributes.
    policy.style_src_attr :unsafe_inline
  end

  # Deriving this from the session id gives a visitor who has no session yet an empty
  # nonce, which matches nothing and blocks the import map.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  # style-src too: Turbo stamps its navigation bar's <style> with the page nonce.
  config.content_security_policy_nonce_directives = %w[ script-src style-src ]
end
