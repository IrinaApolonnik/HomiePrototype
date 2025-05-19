class Admin::NewsletterSubscriptionsController < ApplicationController
  load_and_authorize_resource class: 'NewsletterSubscription'

  def index
    @newsletter_subscriptions = NewsletterSubscription.all
  end

  def destroy
    @newsletter_subscription.destroy!

    respond_to do |format|
      format.html { redirect_to admin_newsletter_subscriptions_path, status: :see_other, notice: "Подписка на рассылку удалена." }
      format.json { head :no_content }
    end
  end

  private

  def set_newsletter_subscription
    @newsletter_subscription = NewsletterSubscription.find(params[:id])
  end
end