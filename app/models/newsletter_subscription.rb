class NewsletterSubscription < ApplicationRecord
    validates :email, presence: true
end
