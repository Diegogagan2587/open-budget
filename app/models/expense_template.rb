class ExpenseTemplate < ApplicationRecord
  belongs_to :category
  has_many :planned_expenses, dependent: :nullify

  validates :name, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :frequency, presence: true, inclusion: { in: %w[weekly biweekly monthly bimonthly quarterly custom] }

  def total_saved
    planned_expenses.where(status: %w[saved paid]).sum(:amount)
  end

  def total_applied
    planned_expenses.where(status: %w[paid transferred spent]).sum(:amount)
  end

  def progress_percentage
    return 0 if total_amount.zero?
    (total_saved / total_amount) * 100
  end

  def remaining_amount
    total_amount - total_saved
  end

  def is_complete?
    total_saved >= total_amount
  end

  def planned_expenses_by_status
    planned_expenses.group(:status).sum(:amount)
  end
end

