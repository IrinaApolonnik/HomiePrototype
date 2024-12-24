module Api
  module V1
    class PostsController < ApplicationController
      before_action :set_post, only: %i[show update destroy]

      # GET /api/v1/posts
      def index
        posts = Post.all
        render json: posts, each_serializer: PostSerializer, status: :ok
      end

      # GET /api/v1/posts/:id
      def show
        render json: @post, serializer: PostSerializer, status: :ok
      end

      # POST /api/v1/posts
      def create
        post = Post.new(post_params)
        if post.save
          render json: post, serializer: PostSerializer, status: :created
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/posts/:id
      def update
        if @post.update(post_params)
          render json: @post, serializer: PostSerializer, status: :ok
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/posts/:id
      def destroy
        @post.destroy
        render json: { message: "Post deleted successfully" }, status: :ok
      end

      private

      def set_post
        @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      def post_params
        params.require(:post).permit(:title, :description, :image_url, :public, :profile_id)
      end
    end
  end
end