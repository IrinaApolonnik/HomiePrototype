class LikeController < ApplicationController

    def toggle
      likeable = Object.const_get(params[:type]).find(params[:id])
      likes = likeable.likes.where(user_id: current_user.id)
  
      if likes && likes.count > 0
        likes.each do |like|
          like.destroy!
        end
      else
        current_user.likes.create!(likeable_type: params[:type], likeable_id: params[:id])
      end
    end
  
end