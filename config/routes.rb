Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token
  resource :registration, only: %i[new create]
  resource :profile, only: %i[show edit update destroy]

  namespace :admin do
    root to: "dashboard#show"
    resources :users do
      member do
        patch :toggle_role
      end
    end
    resources :imports, only: %i[index create show]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
end
