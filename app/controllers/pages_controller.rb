class PagesController < ApplicationController
  def home
    # Redirect to dashboard if user is signed
    if user_signed_in?
      redirect_to dashboard_path
    end
  end
end
