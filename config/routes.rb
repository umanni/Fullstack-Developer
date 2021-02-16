Rails.application.routes.draw do
  root 'homepage#index'

  devise_for :users

  namespace :api do
    resources :users, only: [:show, :update]
    resources :main, only: :index
  end

  get '*', to: 'homepage#index'
end
