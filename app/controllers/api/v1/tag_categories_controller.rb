module Api
  module V1
    class TagCategoriesController < ApplicationController
      before_action :set_tag_category, only: %i[show]

      def index
        tag_categories = TagCategory.order(:name)
        render json: tag_categories, each_serializer: TagCategorySerializer, status: :ok
      end

      def show
        render json: @tag_category, serializer: TagCategorySerializer, status: :ok
      end

      private

      def set_tag_category
        @tag_category = TagCategory.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Tag Category not found" }, status: :not_found
      end

    end
  end
end