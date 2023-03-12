Rails.application.routes.draw do
  get 'dashboard/index'
  devise_for :users, controllers: {
    # Define custom controllers for devise
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  devise_scope :user do
    if Rails.env.development?
      # Create a get route for sign out on devise sessions controller in development mode
      get "users/sign_out" => "users/sessions#destroy", via: :delete
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "dashboard#index"
end
