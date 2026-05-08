class AddOriginIncomeEventToPlannedExpenses < ActiveRecord::Migration[8.0]
  def up
    add_reference :planned_expenses, :origin_income_event, null: true, foreign_key: { to_table: :income_events }

    execute <<~SQL
      UPDATE planned_expenses
      SET origin_income_event_id = income_event_id
      WHERE loan_installment_number IS NOT NULL
    SQL

    remove_index :planned_expenses,
      name: "index_planned_expenses_on_income_event_and_loan_installment"

    add_index :planned_expenses,
      [ :origin_income_event_id, :loan_installment_number ],
      unique: true,
      where: "loan_installment_number IS NOT NULL AND origin_income_event_id IS NOT NULL",
      name: "idx_planned_expenses_on_origin_event_installment"

    add_index :planned_expenses,
      [ :income_event_id, :loan_installment_number ],
      unique: true,
      where: "loan_installment_number IS NOT NULL AND origin_income_event_id IS NULL",
      name: "index_planned_expenses_on_income_event_and_loan_installment"
  end

  def down
    remove_index :planned_expenses,
      name: "idx_planned_expenses_on_origin_event_installment"

    remove_index :planned_expenses,
      name: "index_planned_expenses_on_income_event_and_loan_installment"

    add_index :planned_expenses,
      [ :income_event_id, :loan_installment_number ],
      unique: true,
      where: "loan_installment_number IS NOT NULL",
      name: "index_planned_expenses_on_income_event_and_loan_installment"

    remove_reference :planned_expenses, :origin_income_event, foreign_key: { to_table: :income_events }
  end
end
