class AddRoutingFieldsToExpenses < ActiveRecord::Migration[8.1]
  def change
    add_column :expenses, :counterparty_financial_account_id, :bigint
    add_column :expenses, :counterparty_financial_liability_id, :bigint

    add_index :expenses, :counterparty_financial_account_id
    add_index :expenses, :counterparty_financial_liability_id

    add_foreign_key :expenses, :financial_accounts, column: :counterparty_financial_account_id
    add_foreign_key :expenses, :financial_liabilities, column: :counterparty_financial_liability_id
  end
end
