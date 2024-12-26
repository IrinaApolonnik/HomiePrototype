class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :image_url, :public, :created_at, :updated_at, :tags

  belongs_to :profile
  has_many :items
  has_many :comments
  has_many :likes

  # Форматирование тегов
  def tags
    object.tag_list
  end
end