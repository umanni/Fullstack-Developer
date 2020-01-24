Rails.application.routes.draw do
  devise_for :users
  resources :users_admin, :controller => 'users'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'pages#home'

  namespace :admin do
    resources :users, only: [:index]
  end
end
