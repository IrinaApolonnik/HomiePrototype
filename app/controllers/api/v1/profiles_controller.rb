module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :set_profile, only: [:show, :update]

      def index
        profiles = Profile.all
        render json: profiles, each_serializer: ProfileSerializer
      end

      def show
        render json: @profile, serializer: ProfileSerializer
      end

      def update
        if @profile.update(profile_params)
          render json: @profile, serializer: ProfileSerializer
        else
          render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_profile
        @profile = Profile.find(params[:id])
      end

      def profile_params
        params.require(:profile).permit(:username, :name, :bio, :avatar_url)
      end
    end
  end
end