Rails.application.routes.draw do
  get "like/toggle"
  
  resources :profiles
  devise_for :users

  get 'posts/my_posts', to: 'posts#my_posts', as: :my_posts_posts
  resources :posts
  resources :items
  resources :users, only: [:show]
  resources :posts do
    resources :comments, only: [:create, :destroy]
    collection do
      get "by_tag/:tag", to: "posts#by_tag", as: "tagged"
    end
  end
  resources :subscriptions, only: [:create]

  namespace :admin do
    resources :subscriptions
  end

  namespace :api, format: "json" do
    namespace :v1 do
      resources :posts, only: [:index, :show]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest


  get "welcome/index"
  get "welcome/about"

  # Defines the root path route ("/")
  root "posts#index"
end
