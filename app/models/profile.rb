class Profile < ApplicationRecord
  belongs_to :user

  validates :username, presence: true, uniqueness: true
  validates :avatar_url, presence: true
  validates :name, presence: true

  mount_uploader :avatar_url, ImageUploader

  after_create :create_default_collection

  before_validation :set_default_username, on: :create

  def avatar_url=(url_or_file)
    if url_or_file.is_a?(String) && url_or_file.match?(/http/)
      file = AvatarUploader.new.download_image_from_url(url_or_file)
      super(file)
    else
      super(url_or_file)
    end
  end

  private

  def set_default_username
    self.username ||= "user#{SecureRandom.hex(3)}"
  end

  def create_default_collection
    user.collections.create!(
      title: "Все идеи",
      private: false
    )
  end
end