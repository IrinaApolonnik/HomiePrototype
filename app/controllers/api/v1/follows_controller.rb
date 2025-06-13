module Api
  module V1
    class FollowsController < ApplicationController
      before_action :set_target_user, only: [:create, :destroy]

      # POST /api/v1/follows/:id
      def create
        if current_user.following?(@target_user)
          render json: { message: "Вы уже подписаны", followed: true }, status: :ok
        else
          current_user.followed_users << @target_user
          render json: { message: "Подписка оформлена", followed: true }, status: :created
        end
      end

      # DELETE /api/v1/follows/:id
      def destroy
        if current_user.following?(@target_user)
          current_user.followed_users.delete(@target_user)
          render json: { message: "Подписка удалена", followed: false }, status: :ok
        else
          render json: { message: "Вы не были подписаны", followed: false }, status: :ok
        end
      end

      private

      def set_target_user
        profile = Profile.find_by(id: params[:id])
        if profile.nil?
          render json: { error: "Профиль не найден" }, status: :not_found
        else
          @target_user = profile.user
        end
      end
    end
  end
end
