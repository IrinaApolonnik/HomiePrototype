class ProfileSerializer < ActiveModel::Serializer
    attributes :id, :username, :name, :bio, :avatar_url, :created_at, :updated_at
  
    # Вложенные посты
    has_many :posts
  
    # Вложенные товары
    has_many :items
  
    # Вложенные комментарии
    has_many :comments
  
    # Вложенные лайки
    has_many :likes
  
        # Возвращаем прямую ссылку на аватар
        def avatar_url
            object.avatar_url.url
          end
  end