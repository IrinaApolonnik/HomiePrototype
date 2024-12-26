module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        users = User.all
        render json: users, each_serializer: UserSerializer
      end

      def show
        render json: @user, serializer: UserSerializer
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: :created, serializer: UserSerializer
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: @user, serializer: UserSerializer
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
        render json: { message: 'User deleted successfully' }, status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, profile_attributes: [:username, :name, :avatar_url])
      end
      def me
        render json: current_user, serializer: UserSerializer, status: :ok
      end
    end
  end
end