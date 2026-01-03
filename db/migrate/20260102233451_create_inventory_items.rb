class CreateInventoryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_items do |t|
      t.string :name, null: false
      t.string :stock_state, null: false, default: "in_stock"
      t.boolean :consumable, default: true, null: false
      t.bigint :category_id
      t.text :notes
      t.bigint :account_id, null: false

      t.timestamps
    end

    add_index :inventory_items, :account_id
    add_index :inventory_items, :category_id
    add_index :inventory_items, :stock_state
    add_index :inventory_items, :consumable

    add_foreign_key :inventory_items, :accounts
    add_foreign_key :inventory_items, :categories
  end
end

