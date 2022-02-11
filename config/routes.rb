Rails.application.routes.draw do

  namespace :users_backoffice do
    get 'admin/index'
    post 'admin/import'
    # delete 'admin/:id(.:format)', to :
    resource :admin, only: [:destroy]
    get 'user/index'
  end
  namespace :site do
    get 'welcome/index'
  end

  devise_for :users

  get 'site/welcome/index'
  get 'users_backoffice/user/index', as: :user_root
  get 'backoffice', to: 'users_backoffice/user#index'

  root to: 'site/welcome#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
