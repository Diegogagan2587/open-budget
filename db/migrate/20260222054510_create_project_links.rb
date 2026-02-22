class CreateProjectLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :project_links do |t|
      t.references :project, null: false, foreign_key: true
      t.references :link, null: false, foreign_key: true

      t.timestamps
    end

    add_index :project_links, [:project_id, :link_id], unique: true
  end
end
