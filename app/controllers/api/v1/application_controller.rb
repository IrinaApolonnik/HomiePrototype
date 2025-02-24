module Api
  module V1
    class ApplicationController < ActionController::API
      before_action :authenticate_user!

      private

      def authenticate_user!
        jwt = request.headers["Authorization"]&.split(" ")&.last
        return unless jwt

        begin
          decoded_token = JWT.decode(jwt, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
          User.find_by(jti: decoded_token[0]['jti'])
        rescue JWT::DecodeError
          nil
        end
      end

      def me
        render json: @current_user, serializer: UserSerializer, status: :ok
      end
    end
  end
end