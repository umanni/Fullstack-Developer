class ApplicationController < ActionController::Base
  include Authentication
  include Authorization

  # Prefer progressive enhancement over hard browser blocks for broader support.
  # Documented modern features: CSS nesting, :has(), import maps, and Turbo.
  allow_browser versions: { safari: 17, chrome: 110, firefox: 111, opera: 96, ie: false }

  stale_when_importmap_changes
end
