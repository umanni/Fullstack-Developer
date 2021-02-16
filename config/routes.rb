Rails.application.routes.draw do
  get 'users/update'
  root 'homepage#index'

  devise_for :users, :controllers => { :sessions => 'api/sessions', :registrations => 'api/registrations'}, path: '/api/users'

  namespace :api do
    resources :users, only: [:show, :update]
  end

  match '*path', to: 'homepage#index', via: :all, :as => 'react_base'
end
