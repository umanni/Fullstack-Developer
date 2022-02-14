Rails.application.routes.draw do
  namespace :users_backoffice do
    get 'admin/index'
    post 'admin/import'
    get 'admin/show'
    get 'admin/import_users'
    
    resource :admin, only: [:destroy]
    get 'user/show'
  end
  namespace :site do
    get 'welcome/index'
  end

  # devise_for :users

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  authenticated :user do
    get 'backoffice', to: 'users_backoffice/user#show'
    root to: "users_backoffice/user#show", as: :user_root
  end
  # get 'users_backoffice/user/index', as: :user_root

  unauthenticated :user do

    get 'site/welcome/index'
    root to: 'site/welcome#index'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
