class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token

  def create
    @user = User.new(user_params)

    if @user.save
      # Создаем **один** профиль автоматически
      @user.create_profile!(
        username: "user_#{SecureRandom.hex(3)}",
        name: "New User",
        avatar_url: "https://i.pinimg.com/736x/71/70/0d/71700d2f1fa829ee2a2fa4150f992e4a.jpg"
      )

      render json: {
        messages: "Sign Up Successfully",
        is_success: true,
        jwt: encrypt_payload(@user),
        user: @user.as_json(only: [:id, :email]),
        profile: @user.profile.as_json(only: [:id, :username, :name, :avatar_url])
      }, status: :created
    else
      render json: {
        messages: "Sign Up Failed",
        is_success: false,
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def encrypt_payload(user)
    payload = { email: user.email, jti: user.jti }
    JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key!, 'HS256')
  end
end