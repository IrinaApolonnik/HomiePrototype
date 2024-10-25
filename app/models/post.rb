class Post < ApplicationRecord
    has_many :items, dependent: :destroy
    has_many :comments, :dependent => :destroy
    belongs_to :user
    validates :title, presence: true
end
