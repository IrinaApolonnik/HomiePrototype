class TagSerializer < ActiveModel::Serializer
    attributes :id, :name, :taggings_count, :tag_category_name
  
    # Вложенный атрибут категории
    def tag_category_name
      object.tag_category&.name
    end
  end




  