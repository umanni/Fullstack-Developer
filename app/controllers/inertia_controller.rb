# frozen_string_literal: true

class InertiaController < ApplicationController
  inertia_share auth: -> {
    { user: Current.user ? UserPresenter.new(Current.user).as_json : nil }
  }

  private
    def remove_blank_password!(attributes)
      return if attributes[:password].present?

      attributes.delete(:password)
      attributes.delete(:password_confirmation)
    end
end
