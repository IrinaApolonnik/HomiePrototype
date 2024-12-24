module Api
    module V1
      class LikesController < ApplicationController
        before_action :set_like, only: %i[destroy]
  
        # POST /api/v1/likes
        def create
          like = Like.new(like_params)
          if like.save
            render json: like, status: :created
          else
            render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        # DELETE /api/v1/likes/:id
        def destroy
          @like.destroy
          render json: { message: "Like removed successfully" }, status: :ok
        end
  
        private
  
        def set_like
          @like = Like.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Like not found" }, status: :not_found
        end
  
        def like_params
          params.require(:like).permit(:profile_id, :likeable_id, :likeable_type)
        end
      end
    end
  end