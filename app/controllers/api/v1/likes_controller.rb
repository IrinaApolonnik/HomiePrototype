module Api
  module V1
    class LikesController < ApplicationController
      before_action :set_likeable, only: [:toggle]

      # POST /api/v1/likes/toggle
      def toggle
        return render json: { error: "Ресурс не найден" }, status: :not_found unless @likeable

        like = @likeable.likes.find_by(user_id: current_user.id)

        if like
          like.destroy
          render json: { likes_count: @likeable.likes.count, liked: false }, status: :ok
        else
          @likeable.likes.create!(user: current_user)
          render json: { likes_count: @likeable.likes.count, liked: true }, status: :ok
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # DELETE /api/v1/likes/:id
      def destroy
        like = current_user.likes.find_by(id: params[:id])

        if like
          like.destroy
          render json: { message: "Лайк удалён" }, status: :ok
        else
          render json: { error: "Лайк не найден" }, status: :not_found
        end
      end

      private

      def set_likeable
        klass = params[:likeable_type]&.safe_constantize
        @likeable = klass&.find_by(id: params[:likeable_id])
      rescue NameError
        @likeable = nil
      end
    end
  end
end
