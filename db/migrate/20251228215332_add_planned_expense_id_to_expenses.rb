class AddPlannedExpenseIdToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenses, :planned_expense, null: true, foreign_key: true
  end
end
