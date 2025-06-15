# app/models/item.rb
class Item < ApplicationRecord
  belongs_to :user
  belongs_to :post 
  validates :purchase_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "должна быть корректной ссылкой" }
end

