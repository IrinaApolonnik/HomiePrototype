class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]
  skip_before_action :verify_signed_out_user, only: :destroy
  before_action :load_user, only: :create

  def create
    if @user.valid_password?(sign_in_params[:password])
      render json: {
        messages: "Signed In Successfully",
        is_success: true,
        jwt: encrypt_payload(@user),
        user: @user.as_json(only: [:id, :email]),
        profile: @user.profile.as_json(only: [:id, :username, :name, :avatar_url])
      }, status: :ok
    else
      render json: {
        messages: "Sign In Failed - Unauthorized",
        is_success: false,
        errors: ["Invalid password"]
      }, status: :unauthorized
    end
  end

  def destroy
    user = find_user_from_jwt
    if user
      user.update_column(:jti, SecureRandom.uuid) # Сброс токена
      render json: {
        messages: "Signed Out Successfully",
        is_success: true
      }, status: :ok
    else
      render json: {
        messages: "Sign Out Failed - Unauthorized",
        is_success: false
      }, status: :unauthorized
    end
  end

  private

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end

  def load_user
    @user = User.find_for_database_authentication(email: sign_in_params[:email])
    render json: { messages: "User not found", is_success: false }, status: :unauthorized unless @user
  end

  def encrypt_payload(user)
    payload = { email: user.email, jti: user.jti }
    JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key!, 'HS256')
  end

  def find_user_from_jwt
    jwt = request.headers["Authorization"]
    return nil unless jwt.present?

    begin
      decoded_token = JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
      User.find_by_jti(decoded_token[0]['jti'])
    rescue JWT::DecodeError
      nil
    end
  end
end