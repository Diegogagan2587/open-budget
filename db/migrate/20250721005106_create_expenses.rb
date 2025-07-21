class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.date :date
      t.decimal :amount, precision: 10, scale: 2
      t.string :description
      t.references :category, null: false, foreign_key: true
      t.references :budget_period, null: false, foreign_key: true

      t.timestamps
    end
  end
end
