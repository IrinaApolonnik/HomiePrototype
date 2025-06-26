class NewsletterSubscriptionsController < ApplicationController
  # Авторизация через CanCanCan
  load_and_authorize_resource

  # Создание подписки на рассылку
  def create
    @newsletter_subscription = NewsletterSubscription.new(newsletter_subscription_params)

    respond_to do |format|
      if @newsletter_subscription.save
        # Успешная подписка — перенаправляем на главную с сообщением
        format.html { redirect_to root_path, notice: "Вы успешно подписались на рассылку!" }
      else
        # Ошибка — также редиректим на главную, но с alert
        format.html { redirect_to root_path, alert: "Ошибка при подписке на рассылку." }
      end
    end
  end

  private

  # Разрешённые параметры подписки
  def newsletter_subscription_params
    params.require(:newsletter_subscription).permit(:email)
  end
end
