namespace :uploads do
    desc "Process all images with CarrierWave after seeds"
    task process_images: :environment do
      # Обрабатываем аватары профилей
      Profile.all.each do |profile|
        avatar_url = profile.read_attribute(:avatar_url) # Получаем строку из базы
        next unless avatar_url.present? && avatar_url.match?(/http/)
  
        begin
          uploader = AvatarUploader.new(profile, :avatar_url)
          file = uploader.download_image_from_url(avatar_url)
          if file
            uploader.store!(file)
            profile.update_column(:avatar_url, uploader.url)
            puts "Processed avatar for profile #{profile.id}"
          end
        rescue => e
          puts "Failed to process avatar for profile #{profile.id}: #{e.message}"
        end
      end
  
      # Обрабатываем изображения постов
      Post.all.each do |post|
        image_url = post.read_attribute(:image_url) # Получаем строку из базы
        next unless image_url.present? && image_url.match?(/http/)
  
        begin
          uploader = ImageUploader.new(post, :image_url)
          file = uploader.download_image_from_url(image_url)
          if file
            uploader.store!(file)
            post.update_column(:image_url, uploader.url)
            puts "Processed image for post #{post.id}"
          end
        rescue => e
          puts "Failed to process image for post #{post.id}: #{e.message}"
        end
      end
    end
  end