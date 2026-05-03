class AddRegularIncomeDestinationToIncomeEvents < ActiveRecord::Migration[8.1]
  def change
    add_reference :income_events, :regular_income_destination_asset, foreign_key: { to_table: :financial_accounts }, index: true
    add_reference :income_events, :regular_income_destination_liability, foreign_key: { to_table: :financial_liabilities }, index: true
  end
end
