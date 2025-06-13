class Users::RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    layout "auth"
  
    # Переопределяем метод create
    def create
      build_resource(sign_up_params)
  
      if resource.save
        sign_in(resource)
        render json: { success: true, user_id: resource.id }, status: :ok # Передаем ID пользователя для дальнейших действий
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # Метод для обновления профиля
    def update_profile
      @profile = current_user.profile || current_user.build_profile
  
      if @profile.update(profile_params)
        render json: { success: true }, status: :ok
      else
        render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
      end
    end
    def update
  self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

  # Проверка текущего пароля
  if account_update_params[:current_password].present?
    if resource.update_with_password(account_update_params)
      bypass_sign_in(resource) # не выкидывать из сессии
      flash[:notice] = "Настройки безопасности обновлены."
      redirect_to request.referer || root_path
    else
      flash[:alert] = resource.errors.full_messages.join(', ')
      redirect_to request.referer || root_path
    end
  else
    flash[:alert] = "Введите текущий пароль для подтверждения изменений."
    redirect_to request.referer || root_path
  end
end
  before_action :configure_account_update_params, only: [:update]
    protected
    def configure_account_update_params
  devise_parameter_sanitizer.permit(:account_update, keys: [:email, :password, :password_confirmation, :current_password])
end
  
    # Разрешаем дополнительные параметры для регистрации
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
    end
  
    # Разрешаем параметры для профиля
    def profile_params
      params.require(:profile).permit(:avatar, :name, :username)
    end
  end