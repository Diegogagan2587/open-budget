class CreateShoppingItems < ActiveRecord::Migration[8.0]
  def change
    create_table :shopping_items do |t|
      t.string :name, null: false
      t.string :status, null: false, default: "pending"
      t.string :item_type, null: false, default: "one_time"
      t.string :quantity
      t.decimal :estimated_amount, precision: 10, scale: 2
      t.bigint :category_id
      t.bigint :planned_expense_id
      t.bigint :expense_id
      t.string :frequency
      t.date :last_purchased_at
      t.text :notes
      t.bigint :account_id, null: false

      t.timestamps
    end

    add_index :shopping_items, :account_id
    add_index :shopping_items, :category_id
    add_index :shopping_items, :planned_expense_id
    add_index :shopping_items, :expense_id
    add_index :shopping_items, :status
    add_index :shopping_items, :item_type

    add_foreign_key :shopping_items, :accounts
    add_foreign_key :shopping_items, :categories
    add_foreign_key :shopping_items, :planned_expenses
    add_foreign_key :shopping_items, :expenses
  end
end

