Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]
  resource :profile, only: %i[ show edit update destroy ]

  namespace :admin do
    root "dashboard#show"

    resources :users, except: :show do
      patch :toggle_role, on: :member
    end
    resources :user_imports, only: %i[ index new create show ]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#show"
end
