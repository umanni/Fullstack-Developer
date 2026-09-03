Rails.application.routes.draw do
  root "home#show"

  resource :session, only: %i[ new create destroy ]
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resource :registration, only: %i[ new create ]
  resource :profile, only: %i[ show edit update destroy ]

  namespace :admin do
    root "dashboard#show"
    resources :users, except: :show do
      patch :toggle_role, on: :member
    end
    resources :user_imports, only: %i[ index new create show ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "manifest" => "rails/pwa#manifest", defaults: { format: :json }, as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", defaults: { format: :js }, as: :pwa_service_worker
end
