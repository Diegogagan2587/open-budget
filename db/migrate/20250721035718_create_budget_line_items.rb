class CreateBudgetLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_line_items do |t|
      t.references :budget_period, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :description
      t.decimal :planned_amount, precision: 10, scale: 2
      t.float :percentage_of_total

      t.timestamps
    end
  end
end
