class Like < ApplicationRecord
  belongs_to :profile
  belongs_to :likeable, polymorphic: true, counter_cache: true
end
