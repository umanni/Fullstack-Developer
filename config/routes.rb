Rails.application.routes.draw do
  # Define root path route ("/")
  root 'pages#home'

  # Define routes for devise
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  # Define routes for the dashboard controller
  scope '/dashboard', controller: :dashboard do
    get '/', action: :index, as: :dashboard
    get '/list_users', action: :list_users, as: :list_users
    get '/user/:id', action: :show_user_profile, as: :show_user_profile
    get '/new_user', action: :new_user, as: :new_user
    post '/create_user', action: :create_user, as: :create_user
    get '/new_user_bulk', action: :new_user_bulk, as: :new_user_bulk
    post '/create_user_bulk', action: :create_user_bulk, as: :create_user_bulk
  end

  # Define health check route for load balancers and uptime monitors
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
