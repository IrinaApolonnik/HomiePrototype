class TagCategory < ApplicationRecord
  has_many :tags, dependent: :destroy
end