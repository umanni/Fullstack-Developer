require "sidekiq/web"

Rails.application.routes.draw do
  # This MUST be at the top, outside any 'admin' namespace
  devise_for :users
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # Admin-specific routes
  namespace :admin do
    get "dashboard", to: "dashboard#show"
    resources :users
    patch "users/:id/toggle_role", to: "users#toggle_role", as: :toggle_user_role
    resources :user_imports, only: [ :new, :create, :show ]
  end

  # User Profile routes
  resource :profile, only: [ :show, :edit, :update, :destroy ]

  # Root path
  # This logic will redirect signed-in users correctly
  root "profiles#show"

  # As a fallback, redirect admins to their dashboard if they hit the root
  authenticated :user, ->(u) { u.admin? } do
    root to: "admin/dashboard#show", as: :admin_root
  end

  # Redirect regular users to their profile
  authenticated :user do
    root to: "profiles#show", as: :user_root
  end
end
