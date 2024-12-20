class Users::RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
  
    # Переопределяем метод create
    def create
      super do |resource|
        if resource.persisted?
          # Сохраняем user_id в сессии для второго шага
          session[:user_id] = resource.id
          redirect_to new_users_profile_path and return
        end
      end
    end
  
    protected
  
    # Разрешаем дополнительные параметры для регистрации
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
    end
  
    # Переопределяем after_sign_up_path_for для второго шага
    def after_sign_up_path_for(resource)
      new_users_profile_path
    end
  end