require 'bcrypt'

class AddMultiAccountSupport < ActiveRecord::Migration[8.0]
  # Define model classes for use in data migration
  class Account < ActiveRecord::Base
  end

  class AccountMembership < ActiveRecord::Base
  end

  class User < ActiveRecord::Base
  end

  class BudgetPeriod < ActiveRecord::Base
  end

  class Category < ActiveRecord::Base
  end

  class Expense < ActiveRecord::Base
  end

  class ExpenseTemplate < ActiveRecord::Base
  end

  class IncomeEvent < ActiveRecord::Base
  end

  class PlannedExpense < ActiveRecord::Base
  end

  class BudgetLineItem < ActiveRecord::Base
  end

  def up
    # Create accounts table
    create_table :accounts do |t|
      t.string :name, null: false
      t.timestamps
    end

    # Create account_memberships table
    create_table :account_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :role, null: false, default: 'member'
      t.timestamps
    end

    add_index :account_memberships, [:user_id, :account_id], unique: true

    # Add account_id columns (nullable initially for data migration)
    add_reference :budget_periods, :account, null: true, foreign_key: true
    add_reference :categories, :account, null: true, foreign_key: true
    add_reference :expenses, :account, null: true, foreign_key: true
    add_reference :expense_templates, :account, null: true, foreign_key: true
    add_reference :income_events, :account, null: true, foreign_key: true
    add_reference :planned_expenses, :account, null: true, foreign_key: true
    add_reference :budget_line_items, :account, null: true, foreign_key: true

    # Data migration: Create first account and assign all existing records
    migrate_existing_data_to_first_account

    # Make account_id NOT NULL
    change_column_null :budget_periods, :account_id, false
    change_column_null :categories, :account_id, false
    change_column_null :expenses, :account_id, false
    change_column_null :expense_templates, :account_id, false
    change_column_null :income_events, :account_id, false
    change_column_null :planned_expenses, :account_id, false
    change_column_null :budget_line_items, :account_id, false
  end

  def down
    # Remove account_id columns
    remove_reference :budget_line_items, :account, foreign_key: true
    remove_reference :planned_expenses, :account, foreign_key: true
    remove_reference :income_events, :account, foreign_key: true
    remove_reference :expense_templates, :account, foreign_key: true
    remove_reference :expenses, :account, foreign_key: true
    remove_reference :categories, :account, foreign_key: true
    remove_reference :budget_periods, :account, foreign_key: true

    # Drop tables
    drop_table :account_memberships
    drop_table :accounts
  end

  private

  def migrate_existing_data_to_first_account
    # Find the first user (by created_at)
    first_user = User.order(:created_at).first
    
    # If no users exist, create a default admin user
    if first_user.nil?
      # Check if there are any records that need an account
      has_records = BudgetPeriod.exists? || 
                    Category.exists? || 
                    Expense.exists? || 
                    ExpenseTemplate.exists? || 
                    IncomeEvent.exists? || 
                    PlannedExpense.exists? || 
                    BudgetLineItem.exists?
      
      if has_records
        # Create default admin user with temporary password
        # Handle name field - it might not exist yet at this point in migration
        user_attrs = {
          email_address: "admin@example.com",
          password_digest: BCrypt::Password.create("changeme123")  # Simple password that meets 8 char minimum
        }
        
        # Add name if the column exists
        if User.column_names.include?('name')
          user_attrs[:name] = "Admin User"
        end
        
        first_user = User.create!(user_attrs)
      else
        # No users and no records, nothing to migrate
        return
      end
    end

    # Create first account for the first user
    # Handle case where name column might not exist yet
    user_name = first_user.respond_to?(:name) ? first_user.name : first_user.email_address
    account_name = "#{user_name}'s Account"
    account = Account.find_or_create_by!(name: account_name)

    # Create membership for first user as owner if it doesn't exist
    AccountMembership.find_or_create_by!(user_id: first_user.id, account_id: account.id) do |membership|
      membership.role = 'owner'
    end

    # Assign all existing records to this account
    BudgetPeriod.where(account_id: nil).update_all(account_id: account.id)
    Category.where(account_id: nil).update_all(account_id: account.id)
    Expense.where(account_id: nil).update_all(account_id: account.id)
    ExpenseTemplate.where(account_id: nil).update_all(account_id: account.id)
    IncomeEvent.where(account_id: nil).update_all(account_id: account.id)
    PlannedExpense.where(account_id: nil).update_all(account_id: account.id)
    BudgetLineItem.where(account_id: nil).update_all(account_id: account.id)
  end
end

