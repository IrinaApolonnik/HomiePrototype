module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_comment, only: %i[show update destroy]

      def show
        render json: @comment, serializer: CommentSerializer
      end

      def create
        comment = current_profile.comments.new(comment_params)

        if comment.save
          render json: comment, status: :created, serializer: CommentSerializer
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        return render json: { error: "У вас нет прав для редактирования этого комментария" }, status: :forbidden unless @comment.profile == current_profile

        if @comment.update(comment_params)
          render json: @comment, serializer: CommentSerializer
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        return render json: { error: "У вас нет прав на удаление этого комментария" }, status: :forbidden unless @comment.profile == current_profile

        @comment.destroy
        render json: { message: "Комментарий успешно удалён" }, status: :ok
      end

      private

      def set_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Комментарий не найден" }, status: :not_found
      end

      def comment_params
        params.require(:comment).permit(:body, :post_id, :comment_id)
      end

      def current_profile
        @current_profile ||= current_user.profile
      end
    end
  end
end