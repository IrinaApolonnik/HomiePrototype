# app/services/item_parser.rb

class ItemParser
    def self.parse(url)
        uri = URI.parse(url)
        host = uri.host.downcase
    
        case host
        when /wildberries/
            Parsers::WildberriesParser.new(url).parse
        when /ozon/
            Parsers::OzonParser.new(url).parse
        when /market\.yandex/
            Parsers::YandexMarketParser.new(url).parse
        else
            { success: false, error: "Неизвестный сайт" }
        end
    rescue URI::InvalidURIError => e
      { success: false, error: "Неверная ссылка: #{e.message}" }
    end
  end