class Ability
  include CanCan::Ability

  def initialize(user)
    # Права для гостей
    can :read, Post, public: true   # Гости могут видеть только публичные посты
    can :read, Item                 # Гости могут видеть все товары
    can :read, Comment              # Гости могут видеть все комментарии
    can :create, NewsletterSubscription      # Гости могут подписываться

    # Права для авторизованных пользователей
    return unless user.present?

    # Пользователь может управлять своими постами и товарами
    can :manage, Post, user_id: user.id
    can :manage, Item, user_id: user.id

    # Пользователь может управлять своими подписками
    can :create, Follow
    can :destroy, Follow, follower_id: user.id

    # Пользователь может создавать комментарии
    can :create, Comment

    # Пользователь может удалять свои комментарии
    can :destroy, Comment, user_id: user.id

    # Администратор может управлять всем
    return unless user.admin?
    can :manage, :all
  end
end