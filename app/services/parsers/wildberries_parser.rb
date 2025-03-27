require 'net/http'
require 'json'

module Parsers
  class WildberriesParser
    def initialize(url)
      @url = url
    end

    def parse
        product_id = extract_product_id(@url)
        return { success: false, error: 'Неверная ссылка или не удалось извлечь ID' } unless product_id

        api_url = URI("https://card.wb.ru/cards/detail")
        api_url.query = URI.encode_www_form({
            nm: product_id,
            regions: '80,64,38,4,33,68,30,40,1,66,31,69,22,48,71,114',
            stores: '117673,117501,117986,120602,6159,117042,117069,122258,117558,125238',
            dest: '-1257786',
            resultset: 'catalog',
            locale: 'ru'
        })

        response = Net::HTTP.get(api_url)
        json = JSON.parse(response)

        product = json.dig("data", "products")&.first
        return { success: false, error: 'Товар не найден в JSON' } unless product

        name = product["name"]

        # Вычисление пути к картинке
        bucket = product_id.to_i % 10
        volume = product_id.to_i / 100000
        part = product_id.to_i / 1000

        image_url = "https://basket-16.wbbasket.ru/vol#{volume}/part#{part}/#{product_id}/images/big/1.webp"


        # Получаем цену
        price = product["salePriceU"] || product["priceU"]
        price = price.to_i / 100 if price

        {
          success: true,
          name: name,
          image_url: image_url,
          price: price,
          purchase_url: @url,
          market_icon_url: "https://www.wildberries.ru/favicon.ico"
        }
    rescue => e
      Rails.logger.error("Wildberries JSON parse error: #{e.message}")
      { success: false, error: e.message }
    end

    private

    def extract_product_id(url)
        match = url.match(/catalog\/(\d+)/)
        match[1] if match
    end
  end
end