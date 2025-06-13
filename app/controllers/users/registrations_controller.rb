class Users::RegistrationsController < Devise::RegistrationsController
  layout "auth"
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # Регистрация (через JS, с JSON-ответом)
  def create
    build_resource(sign_up_params)

    if resource.save
      sign_in(resource)
      render json: { success: true, user_id: resource.id }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Обновление пароля
def update
  self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

  respond_to do |format|
    if account_update_params[:current_password].blank?
      format.js do
        render :update_error, locals: { error_messages: ["Введите текущий пароль для подтверждения изменений."] }, status: :unprocessable_entity
      end

    elsif !resource.valid_password?(account_update_params[:current_password])
      format.js do
        render :update_error, locals: { error_messages: ["Текущий пароль введён неверно."] }, status: :unprocessable_entity
      end

    elsif account_update_params[:password].blank?
      format.js do
        render :update_error, locals: { error_messages: ["Новый пароль не может быть пустым."] }, status: :unprocessable_entity
      end

    elsif account_update_params[:password] != account_update_params[:password_confirmation]
      format.js do
        render :update_error, locals: { error_messages: ["Подтверждение пароля не совпадает."] }, status: :unprocessable_entity
      end

    elsif resource.update_with_password(account_update_params)
      bypass_sign_in(resource)
      flash[:notice] = "Настройки безопасности обновлены."
      format.js { render :update_success }

    else
      # на всякий случай, если что-то непредсказуемое пойдёт не так
      error_message = resource.errors.full_messages.presence || ["Не удалось обновить данные."]
      format.js do
        render :update_error, locals: { error_messages: error_message }, status: :unprocessable_entity
      end
    end
  end
end







  # Обновление профиля (из модалки через JS)
  def update_profile
    @profile = current_user.profile || current_user.build_profile

    if @profile.update(profile_params)
      render json: { success: true }, status: :ok
    else
      render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:password, :password_confirmation, :current_password])
  end

  def profile_params
    params.require(:profile).permit(:avatar, :name, :username)
  end
end
