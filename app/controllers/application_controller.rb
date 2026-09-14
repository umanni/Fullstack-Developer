class ApplicationController < ActionController::Base
  include Authentication
  include Authorization

  # The floor is what the built stylesheet needs: Tailwind v4 relies on @property,
  # color-mix() and oklch(). Rails' :modern set (Safari 17.2, Chrome 120) would also
  # turn away iPhones on iOS 16.4 to 17.1 that render the app fine.
  allow_browser versions: { safari: 16.4, chrome: 111, firefox: 128, opera: 97, ie: false }

  inertia_share do
    {
      auth:  { user: Current.user && UserSerializer.new(Current.user).as_json },
      flash: { notice: flash.notice, alert: flash.alert }
    }
  end
end
