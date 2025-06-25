Rails.application.routes.draw do
  # Лайки
  post "like/toggle", to: "likes#toggle", as: "toggle_like"
  resources :notifications, only: [:index] do
    collection do
      patch :mark_all_as_read
    end
  end
resource :notification_settings, only: [:update]





  # Профили — публичный просмотр + подписка
  resources :profiles, only: %i[show index] do
      collection do
        get :suggestions
      end
    member do
      post 'follow',   to: 'follows#create',  as: :follow
      delete 'unfollow', to: 'follows#destroy', as: :unfollow
    end
  end


  # Управление своим профилем
  get "profile/settings", to: "profiles#edit", as: "profile_settings"
  patch "profile", to: "profiles#update", as: "update_profile"


  # Devise маршруты для пользователей
  devise_for :users, controllers: { 
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  get 'settings/:tab', to: 'settings#load_tab', as: :settings_tab

  # Подписки и подписчики
  resources :follows, only: [:create, :destroy]
  
  # Страницы подписчиков и подписок
  get 'profiles/:id/followers', to: 'follows#followers', as: :followers
  get 'profiles/:id/followings', to: 'follows#followings', as: :followings


  # Второй шаг регистрации - обновление профиля
  namespace :users do
    resource :profile, only: %i[update], controller: "registrations", as: "update_profile"
  end

  # Посты
  resources :posts do
    resources :comments, only: %i[create destroy] do
      post :reply, on: :member
    end

    collection do
      get :index   # для filter, sort, tags — всё через /posts
    end
  end


  # Предметы — только парсинг и предпросмотр
  resources :items, only: [] do
    collection do
      post 'fetch_data'
      post 'preview'
    end
  end



  # Подписки на рассылку (мейлы)
  resources :newsletter_subscriptions, only: %i[create destroy]
  namespace :admin do
    resources :newsletter_subscriptions, only: %i[index destroy]
  end

  # Коллекции
resources :collections, only: [:index, :show, :create, :update, :destroy, :new] do
  collection do
    get "user_collections", to: "collections#user_collections" # Получение всех коллекций пользователя
  end

  member do
    post "toggle_post/:post_id", to: "collections#toggle_post", as: "toggle_post" # Добавление/удаление поста
    post "toggle_item/:item_id", to: "collections#toggle_item", as: "toggle_item" # Добавление/удаление товара
  end
end


  # API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      # Аутентификация через Devise + JWT
      devise_scope :user do
        post "sign_up",  to: "registrations#create"
        post "sign_in",  to: "sessions#create"
        post "sign_out", to: "sessions#destroy"
      end

      # Профиль текущего пользователя
      get "me/profile", to: "profiles#me"

      # Профили (просмотр и обновление)
      resources :profiles, only: [:show, :update]

      # Посты
      resources :posts, only: [:index, :show, :create, :update, :destroy]

      # Комментарии
      resources :comments, only: [:show, :create, :update, :destroy]

      # Товары
      resources :items, only: [:show, :create, :update, :destroy]

      # Лайки
      post   "likes/toggle", to: "likes#toggle"
      delete "likes/:id",    to: "likes#destroy"

      # Подписки
      post   "follows/:id",  to: "follows#create"
      delete "follows/:id",  to: "follows#destroy"

      # Коллекции
      resources :collections, only: [:index, :show, :create, :update, :destroy] do
        member do
          post   :toggle_post
          post   :toggle_item
          patch  :update_cover
        end
      end

      # Теги и категории
      resources :tags, only: [:index]
      resources :tag_categories, only: [:index, :show]
    end
  end


  # PWA и здоровье приложения
  get "up", to: "rails/health#show", as: :rails_health_check
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest

  # Страницы приветствия
  get "welcome/index", as: "welcome_index"
  get "welcome/about", as: "welcome_about"

  # Корневой маршрут
  root "posts#index"
end