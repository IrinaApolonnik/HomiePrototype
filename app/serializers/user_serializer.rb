class UserSerializer < ActiveModel::Serializer
    attributes :id, :email, :admin, :created_at, :updated_at
    has_one :profile
end