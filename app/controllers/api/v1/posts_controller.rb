module Api
  module V1
    class PostsController < ApplicationController
      before_action :set_post, only: [:show, :update, :destroy]

      def index
        posts = Post.all
        render json: posts, each_serializer: PostSerializer
      end

      def show
        render json: @post, serializer: PostSerializer
      end

      def create
        post = Post.new(post_params)
        if post.save
          render json: post, status: :created, serializer: PostSerializer
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @post.update(post_params)
          render json: @post, serializer: PostSerializer
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @post.destroy
        render json: { message: 'Post deleted successfully' }, status: :ok
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title, :description, :image_url, :public, :profile_id, tag_list: [])
      end
    end
  end
end