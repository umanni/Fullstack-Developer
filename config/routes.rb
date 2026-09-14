Rails.application.routes.draw do
  resource  :session,      only: %i[new create destroy]
  resources :passwords,    param: :token, only: %i[new create edit update]
  resource  :registration, only: %i[new create]
  resource  :profile,      only: %i[show edit update destroy]

  namespace :admin do
    # Generates `admin_dashboard_path` => /admin
    root "dashboards#show", as: :dashboard

    resources :users do
      resource :role, only: :update, controller: "user_roles"
    end

    resources :imports, only: %i[index new create show]
  end

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  root "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Web app manifest from app/views/pwa, linked in application.html.erb, so Android and iOS
  # can add the app to the home screen and open it standalone.
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
