class Post < ApplicationRecord
    has_many :items, dependent: :destroy
    has_many :comments, :dependent => :destroy
    has_many :likes, as: :likeable

    belongs_to :profile

    validates :title, presence: true

    acts_as_taggable_on :tags
end
