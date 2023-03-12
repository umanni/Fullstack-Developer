class PagesController < ApplicationController
  def home
    # Redirect to dashboard if user is signed in using turbo 
    if user_signed_in?
      redirect_to dashboard_path_url
    end
  end
end
