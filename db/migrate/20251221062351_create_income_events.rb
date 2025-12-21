class CreateIncomeEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :income_events do |t|
      t.references :budget_period, null: true, foreign_key: true
      t.date :expected_date, null: false
      t.decimal :expected_amount, precision: 10, scale: 2, null: false
      t.date :received_date
      t.decimal :received_amount, precision: 10, scale: 2
      t.string :description, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
