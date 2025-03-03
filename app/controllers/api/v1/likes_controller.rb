module Api
  module V1
    class LikesController < ApplicationController
      before_action :set_like, only: [:destroy]

      # POST /api/v1/likes
      def create
        existing_like = current_user.profile.likes.find_by(likeable_id: like_params[:likeable_id], likeable_type: like_params[:likeable_type])

        if existing_like
          render json: { error: "Вы уже лайкнули этот объект" }, status: :unprocessable_entity
        else
          like = current_user.profile.likes.new(like_params)
          if like.save
            render json: like, status: :created
          else
            render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      # DELETE /api/v1/likes/:id
      def destroy
        if @like
          @like.destroy
          render json: { message: "Лайк удалён" }, status: :ok
        else
          render json: { error: "Лайк не найден" }, status: :not_found
        end
      end

      private

      def set_like
        @like = current_user.profile.likes.find_by(id: params[:id])
      end

      def like_params
        params.require(:like).permit(:likeable_id, :likeable_type)
      end
    end
  end
end