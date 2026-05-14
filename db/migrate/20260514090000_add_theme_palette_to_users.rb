class AddThemePaletteToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :theme_palette, :string, null: false, default: "ios-balanced"
  end
end
