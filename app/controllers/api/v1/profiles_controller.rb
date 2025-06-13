module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :set_profile, only: [:show, :update]
      before_action :authorize_user!, only: [:update]

      # GET /api/v1/profiles/me
      def me
        profile = current_user.profile
        if profile
          render json: profile, serializer: ProfileSerializer
        else
          render json: { error: "Профиль не найден" }, status: :not_found
        end
      end

      # GET /api/v1/profiles/:id
      def show
        posts = @profile.user.posts.includes(:likes)
        items = @profile.user.items

        render json: {
          profile: ProfileSerializer.new(@profile),
          posts: ActiveModel::Serializer::CollectionSerializer.new(posts, serializer: PostSerializer),
          items: ActiveModel::Serializer::CollectionSerializer.new(items, serializer: ItemSerializer)
        }
      end

      # PATCH /api/v1/profiles/:id
      def update
        if @profile.update(profile_params)
          render json: @profile, serializer: ProfileSerializer
        else
          render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_profile
        @profile = params[:id] == "me" ? current_user.profile : Profile.find_by(id: params[:id])
        render json: { error: "Профиль не найден" }, status: :not_found unless @profile
      end

      def authorize_user!
        render json: { error: "Вы не можете редактировать этот профиль" }, status: :forbidden unless @profile.user == current_user
      end

      def profile_params
        params.require(:profile).permit(:username, :name, :bio, :avatar_url)
      end
    end
  end
end
