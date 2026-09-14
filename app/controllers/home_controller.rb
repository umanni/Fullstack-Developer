# frozen_string_literal: true

class HomeController < InertiaController
  allow_unauthenticated_access

  def index
    return render inertia: "home/index" unless authenticated?

    flash.keep
    redirect_to default_landing_url
  end
end
