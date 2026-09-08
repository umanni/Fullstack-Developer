# frozen_string_literal: true

class RootController < ApplicationController
  def index
    redirect_to after_authentication_url
  end
end
