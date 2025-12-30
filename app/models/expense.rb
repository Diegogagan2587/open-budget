class Expense < ApplicationRecord
  belongs_to :account
  belongs_to :category
  belongs_to :budget_period, optional: true

  before_validation :set_account, on: :create

  scope :for_account, ->(account) { where(account: account) }

  private

  def set_account
    self.account ||= Current.account if Current.account
  end
end
