class AvatarUploader < CarrierWave::Uploader::Base
  # Хранилище
  storage :file

  # Папка для загрузки
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Допустимые форматы файлов
  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  # Загрузка по URL
  def download_image_from_url(url)
    file = URI.open(url) # Используем open-uri
    file_path = File.join(Dir.tmpdir, File.basename(URI.parse(url).path))
    File.open(file_path, 'wb') { |f| f.write(file.read) }
    File.open(file_path)
  rescue => e
    Rails.logger.error("Failed to download image: #{e.message}")
    nil
  end
end