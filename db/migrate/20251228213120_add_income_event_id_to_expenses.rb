class AddIncomeEventIdToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenses, :income_event, null: true, foreign_key: true
  end
end
