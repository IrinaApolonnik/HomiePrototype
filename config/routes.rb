Rails.application.routes.draw do
  # Лайки
  post "like/toggle", to: "likes#toggle", as: "toggle_like"

  # Профили — публичный просмотр + подписка
  resources :profiles, only: %i[show index] do
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

  # Подписки и подписчики
  resources :follows, only: [:create, :destroy]

  # Второй шаг регистрации - обновление профиля
  namespace :users do
    resource :profile, only: %i[update], controller: "registrations", as: "update_profile"
  end

  # Посты
  resources :posts do
    resources :comments, only: %i[create destroy] do
      member do
        post "reply", to: "comments#reply", as: "reply"
      end
    end

    collection do
      get "sort", to: "posts#sort"
      get "by_tag", to: "posts#by_tag", as: "tagged"
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
  resources :collections, only: [:index, :show, :create, :update, :destroy] do
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
      # Пользователи
      resources :users, only: [:index, :show, :create, :update, :destroy]
      
      # Профили
      get "me/profile", to: "profiles#me"
      resources :profiles, only: [:index, :show, :update]

      # Посты
      resources :posts, only: [:index, :show, :create, :update, :destroy]

      # Товары
      resources :items, only: [:show, :create, :update, :destroy]

      # Комментарии (отдельно)
      resources :comments, only: [:show, :create, :update, :destroy]

      # Лайки
      resources :likes, only: %i[create destroy]

      # Теги
      resources :tags, only: [:index]

      # Категории тегов
      resources :tag_categories, only: %i[index show]


      devise_scope :user do
        post "sign_up", to: "registrations#create"
        post "sign_in", to: "sessions#create"
        post "sign_out", to: "sessions#destroy"
      end
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