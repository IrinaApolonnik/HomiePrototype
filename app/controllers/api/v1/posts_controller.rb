module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :authorize_user!, only: [:update, :destroy]

      def index
        posts = Post.includes(:profile, :likes, :comments).all
        render json: posts, each_serializer: PostSerializer
      end

      def show
        render json: @post, serializer: PostSerializer
      end

      def create
        post = current_user.profile.posts.new(post_params)

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
        render json: { message: "Пост удалён" }, status: :ok
      end

      private

      def set_post
        @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Пост не найден" }, status: :not_found
      end

      def post_params
        params.require(:post).permit(:title, :description, :image_url, :public, tag_list: [])
      end

      def authorize_user!
        unless @post.profile == current_user.profile
          render json: { error: "Вы не можете редактировать или удалять этот пост" }, status: :forbidden
        end
      end
    end
  end
end