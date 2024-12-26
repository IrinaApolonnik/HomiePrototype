module Api
  module V1
    class ItemsController < ApplicationController
      before_action :set_item, only: [:show, :update, :destroy]

      def index
        items = Item.all
        render json: items, each_serializer: ItemSerializer
      end

      def show
        render json: @item, serializer: ItemSerializer
      end

      def create
        item = Item.new(item_params)
        if item.save
          render json: item, status: :created, serializer: ItemSerializer
        else
          render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @item.update(item_params)
          render json: @item, serializer: ItemSerializer
        else
          render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @item.destroy
        render json: { message: 'Item deleted successfully' }, status: :ok
      end

      private

      def set_item
        @item = Item.find(params[:id])
      end

      def item_params
        params.require(:item).permit(:name, :description, :image_url, :purchase_url, :price, :market_icon_url, :profile_id, :post_id)
      end
    end
  end
end