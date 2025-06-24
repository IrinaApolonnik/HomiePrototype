class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  has_many :posts, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :notification_settings, dependent: :destroy


  # Связи подписок
  has_many :follower_relationships, foreign_key: :followed_id, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :followed_users, through: :following_relationships, source: :followed

  def following?(other_user)
    followed_users.include?(other_user)
  end

  after_create :create_default_profile

  before_create :generate_jti

  private

  def create_default_profile
    profile = build_profile(
      username: "user_#{self.id}",
      avatar_url: "https://i.pinimg.com/736x/71/70/0d/71700d2f1fa829ee2a2fa4150f992e4a.jpg",
      name: "New User"
    )
    unless profile.save
      error_messages = profile.errors.full_messages.join(', ')
      raise "Profile creation failed for user ##{self.id}: #{error_messages}"
    end
  end

  def generate_jti
    self.jti = SecureRandom.uuid
  end
end