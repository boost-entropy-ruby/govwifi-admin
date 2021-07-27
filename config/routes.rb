Rails.application.routes.draw do
  root "home#index"

  devise_for :users,
             controllers: {
               confirmations: "users/confirmations",
               registrations: "users/registrations",
               invitations: "users/invitations",
               passwords: "users/passwords",
               two_factor_authentication: "users/two_factor_authentication",
             }

  devise_scope :user do
    post "/check_password_strength", to: "users/registrations#check_password_strength"

    put "users/confirmations", to: "users/confirmations#update"
    get "users/confirmations/pending", to: "users/confirmations#pending"

    put "users/two_factor_authentication_setup", to: "users/two_factor_authentication_setup#update"
    get "users/two_factor_authentication_setup", to: "users/two_factor_authentication_setup#show"

    get "users/:id/two_factor_authentication/edit", to: "users/two_factor_authentication#edit"
    delete "users/:id/two_factor_authentication", to: "users/two_factor_authentication#destroy"
  end
  get "confirm_new_membership", to: "users/memberships#create"

  get "/healthcheck", to: "monitoring#healthcheck"
  get "change_organisation", to: "current_organisation#edit"
  patch "change_organisation", to: "current_organisation#update"
  get "/setup_instructions/poster", to: "setup_instructions#poster"

  resources :status, only: %i[index]
  resources :ips, only: %i[index new create destroy] do
    get "remove", to: "ips#index"
    get "created", to: "ips#index", on: :collection
    get "created/location", to: "ips#index", on: :collection
    get "removed", to: "ips#index", on: :collection
    get "removed/location", to: "ips#index", on: :collection
  end

  resources :help, only: %i[create new] do
    get "/", on: :collection, to: "help#new"
    get "signed_in", on: :new
    get "admin_account", on: :new
    get "technical_support", on: :new
    get "user_support", on: :new
  end
  resources :locations, only: %i[new create destroy update] do
    get "remove", to: "ips#index"
    get "rotate_key", to: "ips#index"
    get "add_ips", to: "add_ips"
    patch "update_ips", to: "update_ips"
  end
  resources :memberships, only: %i[edit update index destroy] do
    collection do
      get "created/invite", to: "memberships#index"
      get "updated/permissions", to: "memberships#index"
      get "removed", to: "memberships#index"
    end
  end
  resources :mou, only: %i[index create] do
    collection do
      get "created", to: "mou#index"
      get "replaced", to: "mou#index"
    end
  end
  resources :logs, only: %i[index]
  resources :logs_searches, path: "logs/search", only: %i[new index create] do
    get "ip", on: :new
    get "username", on: :new
    get "location", on: :new
  end
  resources :organisations, only: %i[new create edit update]
  resources :setup_instructions, only: %i[index] do
    collection do
      get "initial", to: "setup_instructions#index", as: :new_organisation
    end
  end
  resources :overview, only: %i[index]

  namespace :super_admin do
    resources :locations, only: %i[index] do
      collection do
        get "map", to: "locations/map#index"
      end
    end
    resources :mou, only: %i[index update create]
    resources :organisations, only: %i[index show destroy] do
      collection do
        get "service_emails", to: "organisations#service_emails", constraints: { format: "csv" }
      end
    end
    resource :whitelist, only: %i[new create] do
      scope module: "whitelists" do
        resources :email_domains, only: %i[index new create destroy]
        resources :organisation_names, only: %i[index create destroy]
      end
    end

    post "wifi_user_search", to: "wifi_user_search#search"

    namespace "neo" do
      get "dashboard"
    end
  end

  %w[404 422 500].each do |code|
    get code, to: "application#error", code: code
  end
end
