class AddMetadataToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :metadata, :jsonb, null: false, default: {}
    add_index :tasks, :metadata, using: :gin
  end
end
