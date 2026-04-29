class AddFinancialAccountLinksToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenses, :financial_account, null: true, foreign_key: { to_table: :financial_accounts }
    add_reference :expenses, :financial_liability, null: true, foreign_key: { to_table: :financial_liabilities }
  end
end
