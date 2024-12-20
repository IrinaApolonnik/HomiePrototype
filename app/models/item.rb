class Item < ApplicationRecord
  belongs_to :profile
  belongs_to :post, optional: true
end
