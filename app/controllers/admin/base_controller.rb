module Admin
  class BaseController < ApplicationController
    require_admin!
  end
end
