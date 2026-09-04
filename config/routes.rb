Rails.application.routes.draw do
  # Swagger UI, and the generated OpenAPI document it reads.
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  root "home#index"

  resource :locale, only: :update
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create], path: "sign_up", path_names: { new: "" }
  resource :profile, only: %i[show edit update destroy]

  namespace :admin do
    get "dashboard", to: "dashboard#show"
    # No `show`: the list carries everything there is to know about a person,
    # and a route whose action does not exist answers 404 from a path the
    # application itself advertises.
    resources :users, except: :show

    resources :audit_events, only: :index, path: "activity"

    resources :user_imports, only: %i[index new create show] do
      get :template, on: :collection
      get :rejected_rows, on: :member
    end
  end

  # The JSON API. Versioned in the path from the first day, so the second
  # version does not have to be a different application.
  namespace :api do
    namespace :v1 do
      resource :token, only: :create, path: "tokens"
      resource :profile, only: :show, path: "me"
      # `new` and `edit` are routes for rendering forms; a JSON API has none to
      # render, and leaving them defined means two advertised paths that only
      # ever answer 404.
      resources :users, except: %i[new edit]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
