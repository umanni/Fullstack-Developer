Rails.application.routes.draw do
  devise_for :users
  # Root (visitantes)
  root 'pages#home'

  get 'pages/home'

  # Authenticated routes
  authenticated :user do
    root to: 'dashboard#index', as: :authenticated_root
    resource :profile, only: %i[show edit update destroy]
  end

  # Admin routes
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
  end

  # Dashboard público
  get 'dashboard/index'
end