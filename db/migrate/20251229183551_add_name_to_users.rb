class AddNameToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :name, :string, null: true
    # Set default name for existing users
    execute "UPDATE users SET name = split_part(email_address, '@', 1) WHERE name IS NULL"
    change_column_null :users, :name, false
  end

  def down
    remove_column :users, :name
  end
end
