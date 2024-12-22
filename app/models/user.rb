class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  # Автоматическое создание профиля при создании пользователя
  after_create :create_default_profile

  private

  def create_default_profile
    profile = self.build_profile(
      username: "user_#{self.id}",
      avatar_url: "https://i.pinimg.com/736x/71/70/0d/71700d2f1fa829ee2a2fa4150f992e4a.jpg",
      name: "New User"
    )
  
    Rails.logger.info "Profile attributes before save: #{profile.attributes.inspect}"
  
    unless profile.save
      error_messages = profile.errors.full_messages.join(', ')
      raise "Profile creation failed for user ##{self.id}: #{error_messages}"
    end
  end
end