# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, :path_names => { sign_up: "register" }

  get 'profile', to: 'users#show', as: :profile

  devise_scope :user do
    get 'login', to: 'devise/sessions#new'
    get 'logout', to: 'devise/sessions#destroy'
    delete 'logout', to: 'devise/sessions#destroy'
  end

  authenticated :user do
    root to: 'users#show', as: :authenticated_user
  end

  unauthenticated :user do
    devise_scope :user do
      root to: 'devise/sessions#new'
    end
  end

  match '*unmatched_route', to: 'application#route_not_found!', via: :all

end
