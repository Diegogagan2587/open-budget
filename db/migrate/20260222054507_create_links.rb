class CreateLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links do |t|
      t.references :account, null: false, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.text :description
      t.string :link_type, default: "reference", null: false

      t.timestamps
    end

    add_index :links, [ :account_id, :url ], unique: true
  end
end
