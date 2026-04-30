class AddFinancialRoutingToPlannedExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :planned_expenses, :financial_account, null: true, foreign_key: { to_table: :financial_accounts }
    add_reference :planned_expenses, :counterparty_financial_account, null: true, foreign_key: { to_table: :financial_accounts }
    add_reference :planned_expenses, :financial_liability, null: true, foreign_key: { to_table: :financial_liabilities }
  end
end
