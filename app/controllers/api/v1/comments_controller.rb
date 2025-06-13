module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_post, only: [:create]
      before_action :set_comment, only: %i[show update destroy]

      def show
        render json: @comment, serializer: CommentSerializer
      end

      def create
        comment = @post.comments.build(comment_params)
        comment.user = current_user

        if params[:parent_comment_id].present?
          parent = @post.comments.find_by(id: params[:parent_comment_id])

          unless parent
            return render json: { error: 'Родительский комментарий не найден' }, status: :not_found
          end

          comment.comment = parent.root_comment
        end

        if comment.save
          render json: comment, status: :created, serializer: CommentSerializer
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        return render json: { error: "У вас нет прав для редактирования этого комментария" }, status: :forbidden unless @comment.user == current_user

        if @comment.update(comment_params)
          render json: @comment, serializer: CommentSerializer
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        return render json: { error: "У вас нет прав на удаление этого комментария" }, status: :forbidden unless @comment.user == current_user

        @comment.destroy
        render json: { message: "Комментарий успешно удалён" }, status: :ok
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Пост не найден" }, status: :not_found
      end

      def set_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Комментарий не найден" }, status: :not_found
      end

      def comment_params
        params.require(:comment).permit(:body, :comment_id)
      end
    end
  end
end
