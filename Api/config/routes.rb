Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'user_token', to: 'user_token#create'
      # post 'users-import', to: 'users#import'
      
      post 'user-imports', to: 'user_imports#create'
      get 'user-imports', to: 'user_imports#index'
      post 'users/password/change', to: 'users#update_password'
      resources :users, only: %i[index show create update destroy] do
        get 'current', on: :collection
      end
    end
  end
end