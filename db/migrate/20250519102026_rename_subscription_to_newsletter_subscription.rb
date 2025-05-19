class RenameSubscriptionToNewsletterSubscription < ActiveRecord::Migration[7.2]
  def change
    rename_table :subscriptions, :newsletter_subscriptions
  end
end
