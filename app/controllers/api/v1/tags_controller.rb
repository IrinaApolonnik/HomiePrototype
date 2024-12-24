module Api
  module V1
    class TagsController < ApplicationController
      before_action :set_tag, only: %i[show]

      # GET /api/v1/tags
      def index
        tags = Tag.all
        render json: tags, each_serializer: TagSerializer, status: :ok
      end

      # GET /api/v1/tags/:id
      def show
        render json: @tag, serializer: TagSerializer, status: :ok
      end

      private

      def set_tag
        @tag = Tag.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Tag not found" }, status: :not_found
      end
    end
  end
end