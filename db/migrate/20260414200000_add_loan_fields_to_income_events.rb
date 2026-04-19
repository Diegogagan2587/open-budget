class AddLoanFieldsToIncomeEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :income_events, :income_type, :string, null: false, default: "regular"
    add_column :income_events, :loan_amount, :decimal, precision: 10, scale: 2
    add_column :income_events, :interest_rate, :decimal, precision: 6, scale: 3
    add_column :income_events, :number_of_payments, :integer
    add_column :income_events, :payment_frequency, :string
    add_column :income_events, :payment_amount, :decimal, precision: 10, scale: 2
    add_column :income_events, :lender_name, :string
    add_column :income_events, :notes, :text

    add_index :income_events, :income_type
  end
end
