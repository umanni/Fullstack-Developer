Rails.application.routes.draw do
  root "home#index"

  resource :locale, only: :update
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create], path: "sign_up", path_names: { new: "" }
  resource :profile, only: %i[show edit update destroy]

  namespace :admin do
    get "dashboard", to: "dashboard#show"
    resources :users
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
