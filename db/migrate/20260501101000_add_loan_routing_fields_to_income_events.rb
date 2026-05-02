class AddLoanRoutingFieldsToIncomeEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :income_events, :loan_liability, null: true, foreign_key: { to_table: :financial_liabilities }
    add_reference :income_events, :loan_disbursement_destination_asset, null: true, foreign_key: { to_table: :financial_accounts }
    add_reference :income_events, :loan_disbursement_destination_liability, null: true, foreign_key: { to_table: :financial_liabilities }
  end
end
