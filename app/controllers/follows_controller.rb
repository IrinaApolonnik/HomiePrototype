class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    profile = Profile.find(params[:id])
    user_to_follow = profile.user

    current_user.followed_users << user_to_follow unless current_user.following?(user_to_follow)
    redirect_to profile_path(profile), notice: "Вы подписались на пользователя."
  end

  def destroy
    profile = Profile.find(params[:id])
    user_to_unfollow = profile.user

    current_user.followed_users.delete(user_to_unfollow) if current_user.following?(user_to_unfollow)
    redirect_to profile_path(profile), notice: "Вы отписались от пользователя."
  end
end
