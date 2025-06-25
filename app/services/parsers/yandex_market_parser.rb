require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'json'

module Parsers
  class YandexMarketParser
    def initialize(url)
      @url = url
    end

    def parse
      product_id = extract_product_id(@url)
      return { success: false, error: 'Неверная ссылка или не удалось извлечь ID' } unless product_id

      # Загружаем HTML страницы товара
      html = URI.open(@url, "User-Agent" => "Mozilla/5.0").read
      doc = Nokogiri::HTML(html)

      # Извлекаем название товара из заголовка страницы
      name = doc.at('h1')&.text&.strip

      # Ищем в тексте HTML первую цену
      price = nil
      if html =~ /"price":(\d+)(?:,"oldPrice":\d+)?/
        price = $1.to_i
      end

      # Ищем URL изображения товара (первый встреченный)
      image_url = html[/https?:\/\/[^"]+\/get-mpic\/[^"]+\/orig/, 0]

      # Проверяем, удалось ли получить все данные
      unless name && price && image_url
        return { success: false, error: 'Не удалось извлечь информацию о товаре' }
      end

      {
        success: true,
        name: name,
        image_url: image_url,
        price: price,
        purchase_url: @url,
        market_icon_url: "https://market.yandex.ru/favicon.ico"
      }
    rescue => e
      Rails.logger.error("YandexMarket parse error: #{e.message}")
      { success: false, error: e.message }
    end

    private

    def extract_product_id(url)
      # Поддержка URL вида .../product--slug/ID или .../card/slug/ID
      if url =~ %r{market\.yandex\.ru/(?:product--[^/]+|card/[^/]+)/(\d+)}
        $1
      end
    end
  end
end
