module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_comment, only: %i[show update destroy]

      def index
        comments = Comment.all
        render json: comments, each_serializer: CommentSerializer
      end

      def show
        render json: @comment, serializer: CommentSerializer
      end

      def create
        comment = current_user.profile.comments.new(comment_params)

        if comment.save
          render json: comment, status: :created, serializer: CommentSerializer
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @comment.profile == current_user.profile
          if @comment.update(comment_params)
            render json: @comment, serializer: CommentSerializer
          else
            render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "У вас нет прав для редактирования этого комментария" }, status: :forbidden
        end
      end

      def destroy
        if @comment.profile == current_user.profile
          @comment.destroy
          render json: { message: 'Комментарий успешно удалён' }, status: :ok
        else
          render json: { error: "У вас нет прав на удаление этого комментария" }, status: :forbidden
        end
      end

      private

      def set_comment
        @comment = Comment.find(params[:id])
      end

      def comment_params
        params.require(:comment).permit(:body, :post_id, :comment_id)
      end
    end
  end
end