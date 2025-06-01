class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_items, dependent: :destroy
  has_many :posts, through: :collection_items, source: :collectible, source_type: 'Post'
  has_many :items, through: :collection_items, source: :collectible, source_type: 'Item'

  validates :title, presence: true

def cover_image_url
  # Пользователь вручную поставил обложку — используем её
  if image_url.present? && !image_url.include?("dummyimage.com")
    return image_url
  end

  # Собираем все сохранённые посты и товары
  collectibles = (posts + items)
                   .select { |c| c.respond_to?(:created_at) && c.created_at.present? }
                   .sort_by(&:created_at)

  collectibles.reverse! if default?

  # Берём первую нормальную картинку
  collectibles.each do |obj|
    url = obj.image_url.is_a?(String) ? obj.image_url : obj.image_url.url
    if url.present? && !url.include?("dummyimage.com")
      self.update_column(:image_url, url) # Сохраняем в БД
      return url
    end
  end

  # Если ничего не нашли — буква
  letter = generate_letter_image
  self.update_column(:image_url, letter)
  letter
end

  def default?
    self.default == true
  end

  def set_custom_cover(url)
    update!(image_url: url) unless default?
  end

  def grid_images
    images = []

    all_collectibles = (posts + items)
                        .select { |c| c.respond_to?(:created_at) && c.created_at.present? }
                        .sort_by(&:created_at)
                        .reverse

    all_collectibles.each do |collectible|
      next unless collectible.respond_to?(:image_url)

      url = collectible.image_url.is_a?(String) ? collectible.image_url : collectible.image_url.url
      puts url
      next if url.blank? || url.include?("dummyimage.com")

      images << url
      break if images.size >= 4
    end

    images
  end

  private

  def generate_letter_image
    first_letter = title[0].upcase
    "https://dummyimage.com/300x300/cccccc/ffffff.png&text=#{first_letter}"
  end
end