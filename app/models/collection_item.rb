class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :collectible, polymorphic: true
end
