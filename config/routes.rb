Rails.application.routes.draw do
  root 'homepage#index'

  devise_for :users

  namespace :api do
    resources :users, only: [:index, :show, :update, :destroy]
    resources :main, only: :index
  end

  match '*path', to: 'homepage#index', via: [:get]
end
