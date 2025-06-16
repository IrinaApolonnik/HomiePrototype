class FollowsController < ApplicationController
  before_action :authenticate_user!

def create
  profile = Profile.find(params[:id])
  user_to_follow = profile.user
  current_user.followed_users << user_to_follow unless current_user.following?(user_to_follow)

  respond_to do |format|
    if params[:source] == "follows_list"
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("follow_btn_user_#{user_to_follow.id}",
          partial: "follows/follow_button", locals: { user: user_to_follow })
      end
    else
      format.html { redirect_to profile_path(profile), notice: "Вы подписались на пользователя." }
    end
  end
end

def destroy
  profile = Profile.find(params[:id])
  user_to_unfollow = profile.user
  current_user.followed_users.delete(user_to_unfollow)

  respond_to do |format|
    if params[:source] == "follows_list"
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("follow_btn_user_#{user_to_unfollow.id}",
          partial: "follows/follow_button", locals: { user: user_to_unfollow })
      end
    else
      format.html { redirect_to profile_path(profile), notice: "Вы отписались от пользователя." }
    end
  end
end






  def followers
    @profile = Profile.find(params[:id])
    @followers = @profile.user.followers
  end

  def followings
    @profile = Profile.find(params[:id])
    @followings = @profile.user.followed_users
  end


end
