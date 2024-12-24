Rails.application.routes.draw do
  # Лайки
  post "like/toggle", to: "likes#toggle", as: "toggle_like"

  # Профили
  resources :profiles, only: %i[show edit update index] do
    member do
      get "posts", to: "profiles#posts", as: "posts" # Посты пользователя
      delete "avatar", to: "profiles#delete_avatar", as: "delete_avatar" # Удаление аватара
    end
  end

  # Настройки профиля
  get "profile/settings", to: "profiles#edit", as: "profile_settings"

  # Devise маршруты для пользователей
  devise_for :users, controllers: { 
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Второй шаг регистрации - обновление профиля
  namespace :users do
    resource :profile, only: %i[update], controller: "registrations", as: "update_profile"
  end

  # Посты
  resources :posts do
    resources :comments, only: %i[create destroy] do
      member do
        post "reply", to: "comments#reply", as: "reply" # Ответ на комментарий
      end
    end

    collection do
      get "by_tag/:tag", to: "posts#by_tag", as: "tagged" # Посты по тегу
    end
  end

  # Предметы
  resources :items, only: %i[index show create update destroy]

  # Подписки
  resources :subscriptions, only: %i[create destroy]
  namespace :admin do
    resources :subscriptions, only: %i[index destroy]
  end

  # API
  namespace :api, format: "json" do
    namespace :v1 do
      # Пользователи
      resources :users, only: %i[index show]

      # Профили
      resources :profiles, only: %i[index show update]

      # Посты
      resources :posts do
        # Вложенные комментарии
        resources :comments, only: %i[index create], shallow: true
      end

      # Товары
      resources :items, only: %i[index show create update destroy]

      # Комментарии (отдельно)
      resources :comments, only: %i[show update destroy]

      # Лайки
      resources :likes, only: %i[create destroy]

      # Теги
      resources :tags, only: %i[index show]

      # Категории тегов
      resources :tag_categories, only: %i[index show]
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