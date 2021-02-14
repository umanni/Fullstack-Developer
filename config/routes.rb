Rails.application.routes.draw do
  root 'homepage#index'

  devise_for :users, :controllers => { :sessions => 'users/sessions'}, path: '/api/users'

  match '*path', to: 'homepage#index', via: :all
end
