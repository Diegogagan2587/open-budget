class CreatePlannedExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :planned_expenses do |t|
      t.references :income_event, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :expense_template, null: true, foreign_key: true
      t.string :description, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :notes
      t.string :status, null: false
      t.integer :position

      t.timestamps
    end
  end
end
