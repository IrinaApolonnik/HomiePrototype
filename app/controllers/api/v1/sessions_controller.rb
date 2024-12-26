module Api
    module V1
      class SessionsController < ApplicationController
        def create
            user = User.find_by(email: params[:email])

            if user&.valid_password?(params[:password])
            render json: user, serializer: UserSerializer, status: :ok
            else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
            end
        end
      end
    end
  end