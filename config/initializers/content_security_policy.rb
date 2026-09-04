# Be sure to restart your server when you modify this file.

# The policy is deliberately tight: everything the pages need is served from
# this origin, except the web font and the remote avatar URLs a user may point
# at. Inline scripts are allowed only with the per-request nonce, which the
# importmap tags carry automatically.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri    :self
    policy.form_action :self
    policy.object_src  :none
    # Nothing here is meant to be framed, which also covers clickjacking on the
    # destructive admin forms.
    policy.frame_ancestors :none

    policy.script_src :self
    # Google Fonts serves the stylesheet from one host and the font files from
    # another; both are needed for the typeface to load.
    policy.style_src  :self, "https://fonts.googleapis.com"
    policy.font_src   :self, :data, "https://fonts.gstatic.com"
    # Remote avatars are an advertised feature, so any https image is allowed.
    # The scheme itself is still validated on the model: javascript: and data:
    # URLs never reach an img src.
    policy.img_src    :self, :https, :data

    # Action Cable connects back to this same origin over a websocket, which
    # older CSP implementations do not read out of `self`.
    # The block runs against the controller when there is one and against the
    # request otherwise, so it asks for the request either way.
    policy.connect_src :self, lambda {
      http = respond_to?(:request) ? request : self
      "#{http.ssl? ? "wss" : "ws"}://#{http.host_with_port}"
    }
  end

  # A fresh nonce per response. The alternative Rails suggests -- deriving it
  # from the session id -- is friendlier to caching but hands every page of a
  # session the same nonce, which is exactly what a nonce is meant not to be.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
