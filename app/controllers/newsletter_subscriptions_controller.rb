class NewsletterSubscriptionsController < ApplicationController
  load_and_authorize_resource

  def create
    @newsletter_subscription = NewsletterSubscription.new(newsletter_subscription_params)

    respond_to do |format|
      if @newsletter_subscription.save
        format.html { redirect_to root_path, notice: "Вы успешно подписались на рассылку!" }
      else
        format.html { redirect_to root_path, alert: "Ошибка при подписке на рассылку." }
      end
    end
  end

  private

  def newsletter_subscription_params
    params.require(:newsletter_subscription).permit(:email)
  end
end