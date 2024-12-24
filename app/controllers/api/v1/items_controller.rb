module Api
  module V1
    class ItemsController < ApplicationController
      before_action :set_item, only: %i[show update destroy]

      # GET /api/v1/items
      def index
        items = Item.all
        render json: items, each_serializer: ItemSerializer, status: :ok
      end

      # GET /api/v1/items/:id
      def show
        render json: @item, serializer: ItemSerializer, status: :ok
      end

      # POST /api/v1/items
      def create
        item = Item.new(item_params)
        if item.save
          render json: item, serializer: ItemSerializer, status: :created
        else
          render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/items/:id
      def update
        if @item.update(item_params)
          render json: @item, serializer: ItemSerializer, status: :ok
        else
          render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/items/:id
      def destroy
        @item.destroy
        render json: { message: "Item deleted successfully" }, status: :ok
      end

      private

      def set_item
        @item = Item.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Item not found" }, status: :not_found
      end

      def item_params
        params.require(:item).permit(:name, :description, :image_url, :purchase_url, :price, :market_icon_url, :post_id, :profile_id)
      end
    end
  end
end