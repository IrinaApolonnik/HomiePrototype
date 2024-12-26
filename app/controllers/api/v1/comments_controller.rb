module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_comment, only: [:show, :update, :destroy]

      def index
        comments = Comment.all
        render json: comments, each_serializer: CommentSerializer
      end

      def show
        render json: @comment, serializer: CommentSerializer
      end

      def create
        comment = Comment.new(comment_params)
        if comment.save
          render json: comment, status: :created, serializer: CommentSerializer
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @comment.update(comment_params)
          render json: @comment, serializer: CommentSerializer
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        render json: { message: 'Comment deleted successfully' }, status: :ok
      end

      private

      def set_comment
        @comment = Comment.find(params[:id])
      end

      def comment_params
        params.require(:comment).permit(:body, :post_id, :profile_id, :comment_id)
      end
    end
  end
end