module Api
  module V1
    class TagsController < ApplicationController

      # GET /api/v1/tags
      def index
        tags = Tag.all.includes(:tag_category) # Загрузка тегов с категориями
        render json: tags, each_serializer: TagSerializer
      end
      def show
      end

      private

    
    end
  end
end