module Api
  module V1
    class PostsController < ApplicationController
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :authorize_user!, only: [:update, :destroy]

      # GET /api/v1/posts
      def index
        posts = Post.includes(:profile, :likes, :comments)
        render json: posts, each_serializer: PostSerializer
      end

      # GET /api/v1/posts/:id
      def show
        render json: @post, serializer: PostSerializer
      end

      # POST /api/v1/posts
      def create
        profile = current_user&.profile
        return render json: { error: "У вас нет профиля" }, status: :unprocessable_entity unless profile

        post = profile.posts.new(post_params)

        if post.save
          render json: post, status: :created, serializer: PostSerializer
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/posts/:id
      def update
        if @post.update(post_params)
          render json: @post, serializer: PostSerializer
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/posts/:id
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
        unless current_user&.profile&.id == @post.profile_id
          render json: { error: "Вы не можете редактировать или удалять этот пост" }, status: :forbidden
        end
      end
    end
  end
end