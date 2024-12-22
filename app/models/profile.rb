class Profile < ApplicationRecord
    # Ассоциация с пользователем
    belongs_to :user
  
    # Ассоциации с другими сущностями
    has_many :posts, dependent: :destroy
    has_many :items, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :likes, dependent: :destroy
  
    # Валидации
    validates :username, presence: true, uniqueness: true
    validates :avatar_url, presence: true
    validates :name, presence: true

    # mount_uploader :avatar_url, AvatarUploader
  
    # Коллбеки
    before_validation :set_default_username, on: :create
  
    private
  
    # Установить уникальное имя пользователя, если оно не задано
    def set_default_username
      self.username ||= "user#{SecureRandom.hex(3)}"
    end
  end