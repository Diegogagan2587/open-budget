class AddLoanIdToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenses, :loan, foreign_key: { to_table: :income_events }, index: true, null: true
  end
end
