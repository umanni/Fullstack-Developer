Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users
  scope '/role' do
    resources :users
  end
  root to: 'pages#home'
  
  # PAGES GETS
  get 'index', to: 'pages#index'
end
