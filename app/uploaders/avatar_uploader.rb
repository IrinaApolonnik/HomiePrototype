class AvatarUploader < CarrierWave::Uploader::Base
  # Подключаем поддержку MiniMagick для обработки изображений
  include CarrierWave::MiniMagick

  # Выбор хранилища для загрузки файлов
  storage :file
  # storage :fog

  # Переопределяем каталог для хранения загруженных файлов
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Обработка изображений при загрузке
  process resize_to_fit: [300, 300]

  # Создание версии миниатюры
  version :thumb do
    process resize_to_fill: [100, 100]
  end

  # Список допустимых расширений файлов
  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # Переопределяем имя загружаемого файла
  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  private

  # Генерация уникального имени для файла
  def secure_token
    @secure_token ||= SecureRandom.uuid
  end
end