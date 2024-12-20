Rails.application.routes.draw do
  # Лайки
  post "like/toggle", to: "likes#toggle", as: "toggle_like"

  # Профили и пользователи
  resources :profiles, only: [:show, :edit, :update, :index] do
    member do
      get "posts", to: "profiles#posts", as: "posts"
    end
  end
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Посты
  resources :posts do
    resources :comments, only: [:create, :destroy] do
      member do
        post "reply", to: "comments#reply", as: "reply"
      end
    end

    collection do
      get "by_tag/:tag", to: "posts#by_tag", as: "tagged"
      get "my_posts", to: "posts#my_posts", as: "my_posts"
    end
  end

  # Предметы
  resources :items, only: [:index, :show, :create, :update, :destroy]

  # Подписки
  resources :subscriptions, only: [:create, :destroy]
  namespace :admin do
    resources :subscriptions, only: [:index, :destroy]
  end

  # API
  namespace :api, format: "json" do
    namespace :v1 do
      resources :posts, only: [:index, :show]
    end
  end

  # PWA и здоровье приложения
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Страницы приветствия
  get "welcome/index", as: "welcome_index"
  get "welcome/about", as: "welcome_about"

  # Корневой маршрут
  root "posts#index"
end