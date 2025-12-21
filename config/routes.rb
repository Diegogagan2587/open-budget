Rails.application.routes.draw do
  get "dashboard/index"
  # resources :budget_line_items
  # resources :expenses
  # resources :categoryfs
  # resources :categories
  # resources :budget_periods
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  #
  resources :expense_templates

  resources :budget_periods do
    resources :budget_line_items
    resources :expenses, only: [ :new, :create ]
    resources :income_events
  end

  resources :income_events do
    resources :planned_expenses do
      member do
        patch :apply
      end
    end
    member do
      get :receive
      patch :receive
      post :apply_all
    end
  end

  resources :categories
  resources :expenses
  root "dashboard#index"
end
