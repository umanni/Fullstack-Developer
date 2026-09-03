class HomeController < ApplicationController
  allow_unauthenticated_access

  # The root path is a signpost: visitors are sent to sign in, and everyone
  # else lands wherever their role belongs.
  def index
    redirect_to authenticated? ? post_authentication_url_for(Current.user) : new_session_path
  end
end
