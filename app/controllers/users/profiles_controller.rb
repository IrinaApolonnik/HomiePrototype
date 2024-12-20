module Users
    class ProfilesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_profile, only: %i[edit update]
  
      # GET /users/profile/edit
      # Редактирование профиля текущего пользователя
      def edit
      end
  
      # PATCH/PUT /users/profile
      # Обновление профиля текущего пользователя
      def update
        if @profile.update(profile_params)
          redirect_to user_profile_path, notice: "Ваш профиль успешно обновлен."
        else
          render :edit, status: :unprocessable_entity
        end
      end
  
      private
  
      # Устанавливаем профиль текущего пользователя
      def set_profile
        @profile = current_user.profile || current_user.build_profile
      end
  
      # Разрешенные параметры для обновления профиля
      def profile_params
        params.require(:profile).permit(:name, :bio, :avatar)
      end
    end
  end