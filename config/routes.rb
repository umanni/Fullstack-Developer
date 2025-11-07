Rails.application.routes.draw do
  devise_for :users
  
  # Root path
  root 'pages#home'

  get 'pages/home'
  get 'dashboard/index'
  
  # Authenticated routes
  authenticated :user do
    root to: 'dashboard#index', as: :authenticated_root
  end
end