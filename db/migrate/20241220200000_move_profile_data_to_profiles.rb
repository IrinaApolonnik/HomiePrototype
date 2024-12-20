class MoveProfileDataToProfiles < ActiveRecord::Migration[7.0]
  def change
    # Удаляем поля из users
    remove_column :users, :avatar_url, :string
    remove_column :users, :username, :string
    remove_column :users, :profile_name, :string

    # Добавляем поля в profiles, если их нет
    change_table :profiles do |t|
      t.string :username unless column_exists?(:profiles, :username)
      t.string :avatar_url unless column_exists?(:profiles, :avatar_url)
    end

    # Устанавливаем ограничения NOT NULL, если это требуется
    change_column_null :profiles, :username, false, "default_username" # Установите временное значение
    change_column_null :profiles, :avatar_url, false, "default_avatar_url" # Установите временное значение
  end
end