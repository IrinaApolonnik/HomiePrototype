class Post < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  belongs_to :profile

  validates :title, presence: true
  validates :profile, presence: true

  acts_as_taggable_on :tags
  mount_uploader :image_url, ImageUploader

  def image_url=(url_or_file)
    if url_or_file.is_a?(String) && url_or_file.match?(/http/)
      file = ImageUploader.new.download_image_from_url(url_or_file)
      super(file)
    else
      super(url_or_file)
    end
  end
end