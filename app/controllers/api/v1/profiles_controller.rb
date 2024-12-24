module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :set_profile, only: %i[show update]

      # GET /api/v1/profiles
      def index
        profiles = Profile.all
        render json: profiles, each_serializer: ProfileSerializer, status: :ok
      end

      # GET /api/v1/profiles/:id
      def show
        render json: @profile, serializer: ProfileSerializer, status: :ok
      end

      # PATCH/PUT /api/v1/profiles/:id
      def update
        if @profile.update(profile_params)
          render json: @profile, serializer: ProfileSerializer, status: :ok
        else
          render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_profile
        @profile = Profile.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Profile not found" }, status: :not_found
      end

      def profile_params
        params.require(:profile).permit(:username, :name, :bio, :avatar_url)
      end
    end
  end
end