Rails.application.routes.draw do
  resource  :session, only: %i[ new create destroy ]
  resource  :registration, only: %i[ new create ]
  resources :passwords, param: :token, only: %i[ new create edit update ]

  resource :profile, only: %i[ show edit update destroy ]

  namespace :admin do
    resource :dashboard, only: :show

    resources :spreadsheet_imports, only: %i[ index new create show ]

    resources :users, except: :show do
      resource :role, only: :update, module: :users
    end
  end

  # Used by the Compose healthcheck and by Kamal.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#show"
end
