class ProfileSerializer < ActiveModel::Serializer
    attributes :id, :username, :name, :bio, :avatar_url, :created_at, :updated_at
  
    # Связь с пользователем (по `user_id`)
    belongs_to :user
  
    # Связи с другими сущностями
    has_many :posts
    has_many :items
    has_many :comments
    has_many :likes
  end