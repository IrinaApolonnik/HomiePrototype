module Api
  module V1
    class ItemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_item, only: %i[show update destroy]

      def index
        items = Item.all
        render json: items, each_serializer: ItemSerializer
      end

      def show
        render json: @item, serializer: ItemSerializer
      end

      def create
        item = current_user.profile.items.new(item_params)

        if item.save
          render json: item, status: :created, serializer: ItemSerializer
        else
          render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @item.profile == current_user.profile
          if @item.update(item_params)
            render json: @item, serializer: ItemSerializer
          else
            render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "У вас нет прав на редактирование этого предмета" }, status: :forbidden
        end
      end

      def destroy
        if @item.profile == current_user.profile
          @item.destroy
          render json: { message: 'Предмет успешно удален' }, status: :ok
        else
          render json: { error: "У вас нет прав на удаление этого предмета" }, status: :forbidden
        end
      end

      private

      def set_item
        @item = Item.find(params[:id])
      end

      def item_params
        params.require(:item).permit(:name, :description, :image_url, :purchase_url, :price, :market_icon_url, :post_id)
      end
    end
  end
end