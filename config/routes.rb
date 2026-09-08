Rails.application.routes.draw do
  # Authentication
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]

  # Registration (unauthenticated)
  resource :registration, only: %i[new create], path: "register"

  # Profile (authenticated)
  resource :profile, only: %i[show edit update destroy]

  # Admin (Phase 3 CRUD)
  namespace :admin do
    root "dashboard#index"
    resources :users, only: %i[index new create edit update destroy] do
      member do
        patch :toggle_role
      end
    end
    resources :user_imports, only: %i[index new create show]
  end

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  root "root#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
