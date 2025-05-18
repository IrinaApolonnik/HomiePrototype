class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_items, dependent: :destroy
  has_many :posts, through: :collection_items, source: :collectible, source_type: 'Post'
  has_many :items, through: :collection_items, source: :collectible, source_type: 'Item'

  validates :title, presence: true

  before_save :update_cover_image, if: -> { image_url.blank? || collection_items_changed? }

  def set_custom_cover(url)
    update!(image_url: url) # Позволяет пользователю вручную менять обложку
  end

  def update_cover_image
    first_collectible = collection_items.first&.collectible

    if first_collectible.present?
      self.image_url = first_collectible.image_url
    else
      self.image_url = generate_letter_image
    end
  end

  private

  def collection_items_changed?
    collection_items.exists?
  end

  # Генерация буквы из названия коллекции
  def generate_letter_image
    first_letter = title[0].upcase
    "https://dummyimage.com/300x300/cccccc/ffffff.png&text=#{first_letter}"
  end
end