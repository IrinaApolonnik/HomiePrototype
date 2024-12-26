module Api
  module V1
    class TagsController < ApplicationController
      def index
        tags = Tag.all.includes(:tag_category) # Загрузка тегов с категориями
        render json: tags, each_serializer: TagSerializer
      end
    end
  end
end