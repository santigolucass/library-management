Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      devise_for :users, skip: :all

      devise_scope :user do
        post "auth/register", to: "auth/registrations#create"
        post "auth/login", to: "auth/sessions#create"
        delete "auth/logout", to: "auth/sessions#destroy"
      end

      resources :books, only: %i[index create show update destroy]
      resources :borrowings, only: :index do
        collection do
          post :borrow
        end
      end
      post "borrowings/:id/return", to: "borrowings#mark_returned"

      get "dashboard/librarian", to: "dashboards#librarian"
      get "dashboard/member", to: "dashboards#member"
    end
  end
end
