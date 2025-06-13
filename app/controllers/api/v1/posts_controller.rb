module Api
  module V1
    class PostsController < ApplicationController
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :authorize_user!, only: [:update, :destroy]

      # GET /api/v1/posts
      def index
        posts = Post.includes(:user, :likes, :comments).where(public: true)
        render json: posts, each_serializer: PostSerializer
      end

      # GET /api/v1/posts/:id
      def show
        if @post.public || @post.user == current_user
          render json: @post, serializer: PostSerializer
        else
          render json: { error: "У вас нет доступа к этому посту" }, status: :forbidden
        end
      end

      # POST /api/v1/posts
      def create
        post_attrs = post_params.except(:temp_items_json)
        post = current_user.posts.new(post_attrs)

        ActiveRecord::Base.transaction do
          if post.save
            temp_items = JSON.parse(params[:post][:temp_items_json] || "[]")

            if temp_items.empty?
              raise ActiveRecord::Rollback, "Пост не может быть создан без товаров"
            end

            temp_items.each do |item_data|
              post.items.create!(
                name:         item_data["name"],
                purchase_url: item_data["purchase_url"],
                price:        item_data["price"],
                image_url:    item_data["image_url"],
                user:         current_user
              )
            end

            render json: post, status: :created, serializer: PostSerializer
          else
            render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue => e
        render json: { error: "Не удалось создать пост: #{e.message}" }, status: :unprocessable_entity
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
        if params[:post][:tag_list].is_a?(String)
          params[:post][:tag_list] = params[:post][:tag_list].split(',')
        end

        params.require(:post).permit(:title, :description, :image_url, :public, :temp_items_json, tag_list: [])
      end

      def authorize_user!
        unless @post.user_id == current_user.id
          render json: { error: "Вы не можете редактировать или удалять этот пост" }, status: :forbidden
        end
      end
    end
  end
end
