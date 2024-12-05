json.extract! @post, :id, :title, :description, :image_url, :created_at, :updated_at

json.set! :comments do
  json.array! @post.comments, partial: "api/v1/comments/comment", as: :comment
end