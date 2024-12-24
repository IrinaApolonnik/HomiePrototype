module Api
  module V1
    class UsersController < ApplicationController
      # GET /api/v1/users
      def index
        users = User.includes(:profile).all
        render json: users, each_serializer: UserSerializer, status: :ok
      end

      # GET /api/v1/users/:id
      def show
        user = User.find(params[:id])
        render json: user, serializer: UserSerializer, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end
    end
  end
end