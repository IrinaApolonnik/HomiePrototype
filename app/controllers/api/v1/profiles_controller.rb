module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :set_profile, only: [:show, :update]
      before_action :authorize_user!, only: [:update]

      # Получение профиля текущего пользователя
      def me
        profile = current_user.profile
        if profile
          render json: profile, serializer: ProfileSerializer
        else
          render json: { error: "Профиль не найден" }, status: :not_found
        end
      end

      # Просмотр профиля по ID
      def show
        render json: @profile, serializer: ProfileSerializer
      end

      # Обновление профиля
      def update
        if current_user.profile.update(profile_params)
          render json: current_user.profile, serializer: ProfileSerializer
        else
          render json: { errors: current_user.profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_profile
        if params[:id] == "me"
          @profile = current_user.profile
        else
          @profile = Profile.find_by(id: params[:id])
        end
      
        render json: { error: "Профиль не найден" }, status: :not_found unless @profile
      end

      def profile_params
        params.require(:profile).permit(:username, :name, :bio, :avatar_url)
      end

      def authorize_user!
        unless current_user.profile == @profile
          render json: { error: "Вы не можете редактировать этот профиль" }, status: :forbidden
        end
      end
    end
  end
end