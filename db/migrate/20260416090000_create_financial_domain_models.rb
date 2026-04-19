class CreateFinancialDomainModels < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_accounts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :account_type, null: false
      t.string :status, null: false, default: "active"
      t.decimal :opening_balance, precision: 12, scale: 2, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :financial_accounts, [ :account_id, :name ], unique: true
    add_index :financial_accounts, :status

    create_table :financial_liabilities do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :liability_type, null: false
      t.string :status, null: false, default: "active"
      t.decimal :opening_balance, precision: 12, scale: 2, null: false, default: 0
      t.decimal :credit_limit, precision: 12, scale: 2
      t.datetime :archived_at
      t.text :notes

      t.timestamps
    end

    add_index :financial_liabilities, [ :account_id, :name ], unique: true
    add_index :financial_liabilities, :status

    create_table :financial_entries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :financial_account, foreign_key: true
      t.references :counterparty_financial_account, foreign_key: { to_table: :financial_accounts }
      t.references :financial_liability, foreign_key: true
      t.references :expense, foreign_key: true
      t.references :income_event, foreign_key: true
      t.string :entry_type, null: false
      t.date :entry_date, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :description, null: false
      t.text :notes

      t.timestamps
    end

    add_index :financial_entries, [ :account_id, :entry_date ]
    add_index :financial_entries, :entry_type
  end
end
