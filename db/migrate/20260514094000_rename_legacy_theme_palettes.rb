class RenameLegacyThemePalettes < ActiveRecord::Migration[8.1]
  LEGACY_TO_NEW = {
    "ios-balanced" => "executive-calm",
    "ios-ocean" => "ocean-depth",
    "ios-forest" => "forest-mint",
    "ios-sunset" => "sunset-ember"
  }.freeze

  def up
    LEGACY_TO_NEW.each do |legacy_value, new_value|
      execute <<~SQL.squish
        UPDATE users
        SET theme_palette = '#{new_value}'
        WHERE theme_palette = '#{legacy_value}'
      SQL
    end

    change_column_default :users, :theme_palette, from: "ios-balanced", to: "executive-calm"
  end

  def down
    LEGACY_TO_NEW.each do |legacy_value, new_value|
      execute <<~SQL.squish
        UPDATE users
        SET theme_palette = '#{legacy_value}'
        WHERE theme_palette = '#{new_value}'
      SQL
    end

    change_column_default :users, :theme_palette, from: "executive-calm", to: "ios-balanced"
  end
end
