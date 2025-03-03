class TagSerializer < ActiveModel::Serializer
  attributes :id, :name, :taggings_count, :tag_category_name
  
  # Вложенный атрибут категории
  def tag_category_name
    object.tag_category&.name
  end

  # Исправляем taggings_count, чтобы оно брало данные из БД, а не искало ассоциацию
  def taggings_count
    object.read_attribute(:taggings_count) || 0
  end
end