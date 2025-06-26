class FollowsController < ApplicationController
  # Требуем авторизацию пользователя перед любым действием
  before_action :authenticate_user!

  # Создание подписки (фоллов)
  def create
    profile = Profile.find(params[:id])
    user_to_follow = profile.user

    # Добавляем в список подписок, если ещё не подписан
    current_user.followed_users << user_to_follow unless current_user.following?(user_to_follow)

    respond_to do |format|
      if params[:source] == "follows_list"
        # Обновление кнопки подписки через Turbo (на списке подписок)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "follow_btn_user_#{user_to_follow.id}",
            partial: "follows/follow_button",
            locals: { user: user_to_follow }
          )
        end
      else
        # Перенаправление обратно на профиль
        format.html { redirect_to profile_path(profile), notice: "Вы подписались на пользователя." }
      end
    end
  end

  # Удаление подписки (анфоллов)
  def destroy
    profile = Profile.find(params[:id])
    user_to_unfollow = profile.user

    # Удаляем из списка подписок
    current_user.followed_users.delete(user_to_unfollow)

    respond_to do |format|
      if params[:source] == "follows_list"
        # Turbo-обновление кнопки в списке
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "follow_btn_user_#{user_to_unfollow.id}",
            partial: "follows/follow_button",
            locals: { user: user_to_unfollow }
          )
        end
      else
        # Перенаправление на профиль
        format.html { redirect_to profile_path(profile), notice: "Вы отписались от пользователя." }
      end
    end
  end

  # Страница подписчиков пользователя
  def followers
    @profile = Profile.find(params[:id])
    @followers = @profile.user.followers
  end

  # Страница тех, на кого подписан пользователь
  def followings
    @profile = Profile.find(params[:id])
    @followings = @profile.user.followed_users
  end
end
