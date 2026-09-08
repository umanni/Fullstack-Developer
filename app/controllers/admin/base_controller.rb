# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Authorization
  end
end
