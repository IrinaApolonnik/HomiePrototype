class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    @user = User.new(user_params)

    if @user.save
      @user.create_profile!(
        username: generate_unique_username,
        name: "New User",
        avatar_url: default_avatar_url
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

  def default_avatar_url
    view_context.asset_url("profile/defaultAvatar.jpg")
  end

  def generate_unique_username
    loop do
      username = "user_#{SecureRandom.hex(3)}"
      break username unless Profile.exists?(username: username)
    end
  end
end
