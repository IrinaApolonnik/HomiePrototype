class Item < ApplicationRecord
  belongs_to :post, optional: true
end
