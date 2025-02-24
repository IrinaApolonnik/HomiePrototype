module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :set_profile, only: [:show, :update]
      before_action :authorize_user!, only: [:update]

      def show
        render json: current_user.profile, serializer: ProfileSerializer
      end

      def update
        if current_user.profile.update(profile_params)
          render json: current_user.profile, serializer: ProfileSerializer
        else
          render json: { errors: current_user.profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_profile
        @profile = Profile.find_by(id: params[:id])
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