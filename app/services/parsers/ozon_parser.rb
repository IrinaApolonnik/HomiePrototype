module Parsers
  class OzonParser
    def initialize(url)
      @url = url
    end

    def parse
      product_id = extract_product_id(@url)
      return { success: false, error: 'Неверная ссылка или не удалось извлечь ID' } unless product_id

      # Формируем путь и URL для API composer
      uri = URI(@url)
      path = uri.path
      path += '/' unless path.end_with?('/')
      api_uri = URI("https://www.ozon.ru/api/composer-api.bx/page/json/v2")
      api_uri.query = URI.encode_www_form({ url: path })

      # Выполняем GET-запрос к API
      http = Net::HTTP.new(api_uri.host, api_uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(api_uri)
      request['User-Agent'] = "Mozilla/5.0"
      response = http.request(request)
      return { success: false, error: 'Ошибка сети или доступ запрещен' } unless response.code.to_i == 200

      body = response.body
      json = JSON.parse(body)

      # Извлекаем информацию о товаре из виджета webSale
      product_info = nil
      if json['widgetStates']
        json['widgetStates'].each do |widget_key, widget_value|
          if widget_key.include?('webSale')
            data = JSON.parse(widget_value)
            product_info = data.dig('cellTrackingInfo', 'product')
            break
          end
        end
      end
      return { success: false, error: 'Товар не найден в JSON' } unless product_info

      name = product_info['title'] || product_info['name']
      # Берем финальную цену, если есть (иначе обычную)
      price = product_info['finalPrice'] || product_info['price']
      price = price.to_i if price

      # Находим ссылку на изображение (первую .jpg ссылку в JSON)
      image_url = body[/https?:\/\/[^"]+\/s3\/multimedia-[^"]+\.jpg/, 0]

      return { success: false, error: 'Товар не найден в JSON' } unless name && price

      {
        success: true,
        name: name,
        image_url: image_url,
        price: price,
        purchase_url: @url,
        market_icon_url: "https://www.ozon.ru/favicon.ico"
      }
    rescue => e
      Rails.logger.error("Ozon parse error: #{e.message}")
      { success: false, error: e.message }
    end

    private

    def extract_product_id(url)
      if url =~ %r{ozon\.ru/product/[^/]+/(\d+)}
        $1
      end
    end
  end
end
