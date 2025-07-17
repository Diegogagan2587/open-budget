class CreateBudgetPeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_periods do |t|
      t.string :name
      t.string :period_type
      t.date :start_date
      t.date :end_date
      t.decimal :total_amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
