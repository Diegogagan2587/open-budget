class Expense < ApplicationRecord
  belongs_to :account
  belongs_to :category
  belongs_to :budget_period
  belongs_to :income_event, optional: true
  belongs_to :planned_expense, optional: true
  has_one :shopping_item, dependent: :nullify

  before_validation :set_account, on: :create

  scope :for_account, ->(account) { where(account: account) }

  private

  def set_account
    self.account ||= Current.account if Current.account
  end
end
