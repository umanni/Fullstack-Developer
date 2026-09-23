Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]
  resource :registration, only: %i[new create]
  resource :profile, only: %i[show edit update destroy]

  namespace :admin do
    resource :dashboard, only: :show
    resources :users do
      member do
        patch :toggle_role
      end
    end
    resources :imports, only: %i[index new create show]
  end

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create update destroy]
    end
  end

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check

  mount MissionControl::Jobs::Engine, at: "/jobs"
  
end
