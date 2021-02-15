Rails.application.routes.draw do
  root 'homepage#index'

  devise_for :users, :controllers => { :sessions => 'users/sessions', :registrations => 'users'}, path: '/api/users'
  devise_scope :user do
    get '/api/users/:id' => 'users#edit', :as => 'user_show'
  end

  match '*path', to: 'homepage#index', via: :all, :as => 'react_base'
end
