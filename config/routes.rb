Rails.application.routes.draw do
  # Health check
  get 'health', to: 'health#check'

  # Root
  root 'home#index'

  # Devise routes
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # Guest session
  post 'guest_session', to: 'guest_sessions#create', as: 'guest_session'

  # User profile
  resource :profile, only: [:show, :edit, :update, :destroy], controller: 'profiles'

  # Admin namespace
  namespace :admin do
    root 'dashboards#show'
    get 'dashboard', to: 'dashboards#show'
    
    resources :users do
      member do
        patch :toggle_role
      end
    end

    resources :imports, only: [:index, :new, :create, :show] do
      member do
        get :status
      end
    end
  end

  # ActionCable
  mount ActionCable.server => '/cable'

  # Sidekiq UI (protected by admin authentication)
  require 'sidekiq/web'
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end

