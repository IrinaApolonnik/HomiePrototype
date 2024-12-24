module Api
    module V1
      class TagCategoriesController < ApplicationController
        before_action :set_tag_category, only: %i[show]
  
        # GET /api/v1/tag_categories
        def index
          tag_categories = TagCategory.all
          render json: tag_categories, each_serializer: TagCategorySerializer, status: :ok
        end
  
        # GET /api/v1/tag_categories/:id
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