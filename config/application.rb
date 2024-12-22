require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HseRailsProjectsHomiePrototype
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Установим часовой пояс
    config.time_zone = 'Moscow'
    config.active_record.default_timezone = :local

    # Настройки для acts-as-taggable-on
    config.after_initialize do
      ActsAsTaggableOn.force_lowercase = true
      ActsAsTaggableOn.delimiter = ','
      ActsAsTaggableOn.remove_unused_tags = true
    end
  end
end