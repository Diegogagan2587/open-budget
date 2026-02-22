class CreateDocs < ActiveRecord::Migration[8.0]
  def change
    create_table :docs do |t|
      t.references :account, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content
      t.string :url
      t.string :doc_type, default: "note", null: false

      t.timestamps
    end

    add_index :docs, [ :account_id, :title ], unique: true
  end
end
