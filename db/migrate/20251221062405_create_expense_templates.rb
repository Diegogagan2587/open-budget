class CreateExpenseTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_templates do |t|
      t.string :name, null: false
      t.references :category, null: false, foreign_key: true
      t.string :description
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :frequency, null: false
      t.text :notes

      t.timestamps
    end
  end
end
