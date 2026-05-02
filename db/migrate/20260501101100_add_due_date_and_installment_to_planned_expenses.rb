class AddDueDateAndInstallmentToPlannedExpenses < ActiveRecord::Migration[8.0]
  def change
    add_column :planned_expenses, :due_date, :date
    add_column :planned_expenses, :loan_installment_number, :integer

    add_index :planned_expenses,
      [ :income_event_id, :loan_installment_number ],
      unique: true,
      where: "loan_installment_number IS NOT NULL",
      name: "index_planned_expenses_on_income_event_and_loan_installment"
  end
end
