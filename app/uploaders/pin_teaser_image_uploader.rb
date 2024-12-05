require "vips"

class PostTeaserImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  include CarrierWave::Vips
  include CarrierWave::ImageOptimizer

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # version :with_text do
  #   process :teaser
  # end
  
  # def teaser
  #   background = Vips::Image.new_from_file(self.file.path)

  #   text = {
  #     font: 'Helvetica',
  #     width: 1000,
  #     spacing: 10,
  #     dpi: 300,
  #     resize: 0.6,
  #     image: nil
  #   }

  #   text[:image] = Vips::Image.text(
  #     "Test test test",
  #     font: text[:font],
  #     width: text[:width],
  #     spacing: text[:spacing],
  #     dpi: text[:dpi]
  #   ).resize(
  #     text[:resize]
  #   )

  #   alpha = text[:image].cast 'uchar'

  #   overlay = text[:image].new_from_image([0, 0, 0])
  #               .copy(interpretation: 'srgb')
  #               .bandjoin(alpha)

  #   background
  #     .composite(
  #       overlay,
  #       'over'
  #     )
    
  #   background.write_to_file(self.file.path)
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_allowlist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end