module Api
  module V1
    class TagsController < ApplicationController
      # GET /api/v1/tags
      def index
        tags = Tag.includes(:tag_category)
        tags = tags.where(tag_category_id: params[:category_id]) if params[:category_id].present?
        tags = tags.order(:name) # Сортировка по алфавиту
        render json: tags, each_serializer: TagSerializer
      end
    end
  end
end