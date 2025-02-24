class CommentSerializer < ActiveModel::Serializer
    attributes :id, :body, :commenter, :created_at, :updated_at
  
    belongs_to :post
    belongs_to :profile
    has_many :replies
  
    # Вложенные данные для ответов
    class ReplySerializer < ActiveModel::Serializer
      attributes :id, :body, :commenter, :created_at, :updated_at
    end
end