Rails.application.routes.draw do
  # Define root path route ("/")
  root 'pages#home'

  # Define routes for the dashboard controller
  scope '/dashboard', controller: :dashboard do
    get '/', action: :index, as: :dashboard
    get '/list_users', action: :list_users, as: :list_users
    get '/new_user_bulk', action: :new_user_bulk, as: :new_user_bulk
    post '/create_user_bulk', action: :create_user_bulk, as: :create_user_bulk
  end

  # Define routes for devise
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # Define custom route for sign out in development mode only
  if Rails.env.development?
    devise_scope :user do
      get 'users/sign_out', to: 'users/sessions#destroy', via: :delete
    end
  end

  # Define health check route for load balancers and uptime monitors
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
