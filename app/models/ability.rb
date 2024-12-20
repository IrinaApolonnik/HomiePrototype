class Ability
  include CanCan::Ability

  def initialize(user)
    # Дефолтные права для гостей (неавторизованных пользователей)
    can :read, Post, public: true # Гости могут видеть только публичные посты
    can :read, Item               # Гости могут видеть все товары
    can :read, Comment            # Гости могут видеть все комментарии
    can :create, Subscription     # Гости могут подписываться

    # Права для авторизованных пользователей
    return unless user.present? # Если пользователь авторизован:
    
    # Пользователь может:
    can :manage, Post, profile: user.profile # Управлять своими постами
    can :manage, Item, profile: user.profile # Управлять своими товарами
    can :create, Comment                     # Создавать комментарии
    can :destroy, Comment, profile: user.profile # Удалять свои комментарии

    # Дополнительные права для администраторов
    return unless user.admin? # Если пользователь администратор:
    can :manage, :all         # Администратор может управлять всем
  end
end