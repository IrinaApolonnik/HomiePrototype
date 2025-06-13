module Api
  module V1
    class ItemsController < ApplicationController
      before_action :set_item, only: %i[show update destroy]

      def show
        render json: @item, serializer: ItemSerializer
      end

      def create
        item = current_user.items.new(item_params)

        if item.save
          render json: item, status: :created, serializer: ItemSerializer
        else
          render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @item.user == current_user
          if @item.update(item_params)
            render json: @item, serializer: ItemSerializer
          else
            render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "Вы не можете редактировать этот товар" }, status: :forbidden
        end
      end

      def destroy
        if @item.user == current_user
          @item.destroy
          render json: { message: "Товар успешно удалён" }, status: :ok
        else
          render json: { error: "Вы не можете удалить этот товар" }, status: :forbidden
        end
      end

      private

      def set_item
        @item = Item.find_by(id: params[:id], user: current_user)
        render json: { error: "Товар не найден или у вас нет прав на него" }, status: :not_found unless @item
      end

      def item_params
        params.require(:item).permit(:name, :description, :image_url, :purchase_url, :price, :market_icon_url, :post_id)
      end
    end
  end
end
