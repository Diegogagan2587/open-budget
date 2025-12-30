class Account < ApplicationRecord
  has_many :account_memberships, dependent: :destroy
  has_many :users, through: :account_memberships

  has_many :budget_periods, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :expense_templates, dependent: :destroy
  has_many :income_events, dependent: :destroy
  has_many :planned_expenses, dependent: :destroy
  has_many :budget_line_items, dependent: :destroy

  validates :name, presence: true

  def owner
    account_memberships.owners.first&.user
  end
end

