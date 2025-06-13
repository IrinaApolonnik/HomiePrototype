module Api
  module V1
    class CollectionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_collection, only: %i[show update destroy toggle_post toggle_item update_cover]
      before_action :authorize_user!, only: %i[update destroy toggle_post toggle_item update_cover]

      def index
        collections = current_user.collections.order(updated_at: :desc)
        render json: collections.as_json(only: [:id, :name, :image_url, :private, :default])
      end

      def show
        render json: @collection.as_json(
          only: [:id, :name, :image_url, :private],
          include: {
            posts: { only: [:id, :title, :image_url] },
            items: { only: [:id, :name, :image_url] }
          }
        )
      end

      def create
        collection = current_user.collections.new(collection_params)

        if collection.save
          render json: { success: true, collection: collection }, status: :created
        else
          render json: { success: false, errors: collection.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @collection.update(collection_params)
          render json: { success: true, collection: @collection }, status: :ok
        else
          render json: { success: false, errors: @collection.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @collection.destroy!
        render json: { success: true, message: "Коллекция удалена." }, status: :ok
      end

      def toggle_post
        post = Post.find_by(id: params[:post_id])
        return render json: { success: false, error: "Пост не найден" }, status: :not_found unless post

        if @collection.posts.include?(post)
          @collection.posts.delete(post)
          update_collection_cover
          render json: { success: true, saved: false }
        else
          @collection.posts << post
          update_collection_cover
          render json: { success: true, saved: true }
        end
      end

      def toggle_item
        item = Item.find_by(id: params[:item_id])
        return render json: { success: false, error: "Предмет не найден" }, status: :not_found unless item

        if @collection.items.include?(item)
          @collection.items.delete(item)
          update_collection_cover
          render json: { success: true, saved: false }
        else
          @collection.items << item
          update_collection_cover
          render json: { success: true, saved: true }
        end
      end

      def update_cover
        if params[:image_url].present?
          @collection.set_custom_cover(params[:image_url])
          render json: { success: true, image_url: @collection.image_url }
        else
          render json: { success: false, error: "Изображение не передано" }, status: :unprocessable_entity
        end
      end

      private

      def set_collection
        @collection = current_user.collections.find_by(id: params[:id])
        render json: { success: false, error: "Коллекция не найдена" }, status: :not_found unless @collection
      end

      def authorize_user!
        render json: { success: false, error: "Нет доступа" }, status: :forbidden unless @collection.user_id == current_user.id
      end

      def collection_params
        params.require(:collection).permit(:name, :private, :image_url)
      end

      def update_collection_cover
        return if @collection.image_url.present? && !@collection.default?
        @collection.image_url = @collection.cover_image_url
        @collection.save! if @collection.changed?
      end
    end
  end
end
