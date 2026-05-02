class AddCounterpartyLiabilityToFinancialEntries < ActiveRecord::Migration[8.0]
  def change
    add_reference :financial_entries, :counterparty_financial_liability, null: true, foreign_key: { to_table: :financial_liabilities }
  end
end
