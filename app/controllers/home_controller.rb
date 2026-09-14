class HomeController < ApplicationController
  def show
    redirect_to home_url_for(Current.user)
  end
end
