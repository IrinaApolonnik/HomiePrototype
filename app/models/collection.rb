class Collection < ApplicationRecord
  belongs_to :user

  has_many :collection_items, dependent: :destroy
  has_many :posts, through: :collection_items, source: :collectible, source_type: 'Post'
  has_many :items, through: :collection_items, source: :collectible, source_type: 'Item'

  validates :title, presence: true

  # Подключение CarrierWave
  mount_uploader :image_url, ImageUploader

  def default?
    self.default == true
  end

  def cover_image_url
    # Если пользователь сам загрузил обложку — показываем её
    return image_url.url if image_url.present? && !image_url.url.include?("dummyimage.com")

    # Ищем первую подходящую картинку из сохранённых постов/товаров
    collectibles = (posts + items)
      .select { |c| c.respond_to?(:created_at) && c.created_at.present? }
      .sort_by(&:created_at)

    collectibles.reverse! if default?

    collectibles.each do |obj|
      url = obj.image_url.is_a?(String) ? obj.image_url : obj.image_url&.url
      if url.present? && !url.include?("dummyimage.com")
        self.update_column(:image_url, url) # Сохраняем в БД
        return url
      end
    end

    # Ничего не нашлось — используем заглушку-букву
    letter = generate_letter_image
    self.update_column(:image_url, letter)
    letter
  end

  def set_custom_cover(url)
    update!(image_url: url) unless default?
  end

  def grid_images
    images = []

    all_collectibles = (posts + items)
      .select { |c| c.respond_to?(:created_at) && c.created_at.present? }
      .sort_by(&:created_at).reverse

    all_collectibles.each do |collectible|
      next unless collectible.respond_to?(:image_url)

      url = collectible.image_url.is_a?(String) ? collectible.image_url : collectible.image_url&.url
      next if url.blank? || url.include?("dummyimage.com")

      images << url
      break if images.size >= 4
    end

    images
  end
  def includes_post?(post)
  posts.exists?(post.id)
end

def includes_item?(item)
  items.exists?(item.id)
end

def self.default_for(user)
  user.collections.find_by(default: true)
end

def add_with_default!(collectible)
  transaction do
    # Добавляем в текущую коллекцию
    collection_items.create!(collectible: collectible) unless includes_collectible?(collectible)

    # Ищем и добавляем в дефолтную, если это не она
    if !default? && (default_collection = Collection.default_for(user))
      default_collection.collection_items.find_or_create_by!(collectible: collectible)
    end
  end
end

def includes_collectible?(collectible)
  case collectible
  when Post
    includes_post?(collectible)
  when Item
    includes_item?(collectible)
  else
    false
  end
end


  private

  def generate_letter_image
    first_letter = title.to_s[0].to_s.upcase
    "https://dummyimage.com/300x300/cccccc/ffffff.png&text=#{first_letter}"
  end
end
