Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  
  devise_for :users
  devise_scope :user do
    root to: "devise/sessions#new"
  end

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :users
    resources :user_bulks, only: [:index, :new, :create]
  end

  get 'user/profile'
end
