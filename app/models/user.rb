class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  after_create :create_default_profile

  private

  def create_default_profile
    self.create_profile!(
      username: "user_#{self.id}",
      avatar_url: "default_avatar_url", # Укажите реальный URL аватара по умолчанию
      name: "New User"
    )
  end
end