class PagesController < ApplicationController
  skip_before_action :authenticate_user!, :only => "reply", :raise => false

  def home
  end
end
