class CreateDocLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :doc_links do |t|
      t.references :doc, null: false, foreign_key: true
      t.references :link, null: false, foreign_key: true

      t.timestamps
    end

    add_index :doc_links, [ :doc_id, :link_id ], unique: true
  end
end
