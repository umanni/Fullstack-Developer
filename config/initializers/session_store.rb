# Be sure to restart your server when you modify this file.

# Rails already defaults to these, but the flags on the cookie that carries a
# signed-in session are worth stating out loud rather than inheriting: no
# script may read it, and it does not ride along on a cross-site request.
# `secure` is not set here -- ActionDispatch::SSL adds it in production, where
# `force_ssl` is on, so development over plain http keeps working.
Rails.application.config.session_store :cookie_store,
                                       key: "_user_management_session",
                                       httponly: true,
                                       same_site: :lax
