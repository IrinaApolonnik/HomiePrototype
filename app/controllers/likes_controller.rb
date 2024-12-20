class LikesController < ApplicationController
  before_action :authenticate_user!

  def toggle
    likeable = find_likeable

    if likeable.nil?
      render json: { error: "Resource not found" }, status: :not_found
      return
    end

    like = likeable.likes.find_by(profile_id: current_profile.id)

    if like
      like.destroy!
      render json: { likes_count: likeable.likes.count, liked: false }, status: :ok
    else
      likeable.likes.create!(profile_id: current_profile.id)
      render json: { likes_count: likeable.likes.count, liked: true }, status: :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def find_likeable
    klass = params[:type].safe_constantize
    klass&.find_by(id: params[:id])
  rescue NameError
    nil
  end
end