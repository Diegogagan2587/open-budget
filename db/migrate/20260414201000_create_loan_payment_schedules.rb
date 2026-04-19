class CreateLoanPaymentSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :loan_payment_schedules do |t|
      t.references :account, null: false, foreign_key: true
      t.references :loan, null: false, foreign_key: { to_table: :income_events }
      t.date :due_date, null: false
      t.integer :installment_number, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :principal_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :interest_amount, precision: 10, scale: 2, null: false, default: 0
      t.string :status, null: false, default: "scheduled"
      t.date :paid_at
      t.timestamps
    end

    add_index :loan_payment_schedules, [ :loan_id, :installment_number ], unique: true
    add_index :loan_payment_schedules, [ :loan_id, :due_date ]
    add_index :loan_payment_schedules, :status
  end
end
