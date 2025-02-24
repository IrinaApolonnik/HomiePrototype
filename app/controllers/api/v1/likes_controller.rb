module Api
  module V1
    class LikesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_like, only: %i[destroy]

      # POST /api/v1/likes
      def create
        like = current_user.profile.likes.new(like_params)

        if like.save
          render json: like, status: :created
        else
          render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/likes/:id
      def destroy
        if @like.profile == current_user.profile
          @like.destroy
          render json: { message: "Лайк удалён" }, status: :ok
        else
          render json: { error: "У вас нет прав на удаление этого лайка" }, status: :forbidden
        end
      end

      private

      def set_like
        @like = Like.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Лайк не найден" }, status: :not_found
      end

      def like_params
        params.require(:like).permit(:likeable_id, :likeable_type)
      end
    end
  end
end