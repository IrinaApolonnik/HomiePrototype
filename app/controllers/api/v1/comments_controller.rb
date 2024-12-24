module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_comment, only: %i[show update destroy]

      # GET /api/v1/comments
      def index
        comments = Comment.all
        render json: comments, each_serializer: CommentSerializer, status: :ok
      end

      # GET /api/v1/comments/:id
      def show
        render json: @comment, serializer: CommentSerializer, status: :ok
      end

      # POST /api/v1/comments
      def create
        comment = Comment.new(comment_params)
        if comment.save
          render json: comment, serializer: CommentSerializer, status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/comments/:id
      def update
        if @comment.update(comment_params)
          render json: @comment, serializer: CommentSerializer, status: :ok
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/comments/:id
      def destroy
        @comment.destroy
        render json: { message: "Comment deleted successfully" }, status: :ok
      end

      private

      def set_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Comment not found" }, status: :not_found
      end

      def comment_params
        params.require(:comment).permit(:body, :post_id, :profile_id, :comment_id)
      end
    end
  end
end