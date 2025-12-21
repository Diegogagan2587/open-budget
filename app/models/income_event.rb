class IncomeEvent < ApplicationRecord
  belongs_to :budget_period, optional: true
  has_many :planned_expenses, dependent: :destroy

  validates :expected_date, presence: true
  validates :expected_amount, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending received applied] }

  scope :pending, -> { where(status: 'pending') }
  scope :received, -> { where(status: 'received') }
  scope :applied, -> { where(status: 'applied') }
  scope :by_date, -> { order(expected_date: :desc) }

  def total_planned
    planned_expenses.sum(:amount)
  end

  def remaining_budget
    income_amount = received_amount || expected_amount
    income_amount - total_planned
  end

  def planned_expenses_ordered
    planned_expenses.order(:position, :created_at)
  end

  def receive!(date, amount)
    update!(
      received_date: date,
      received_amount: amount,
      status: 'received'
    )
  end

  def apply_all!
    planned_expenses.where.not(status: %w[paid transferred spent]).find_each do |planned_expense|
      planned_expense.apply!
    end
    update!(status: 'applied')
  end

  def is_received?
    received_date.present?
  end

  def is_applied?
    status == 'applied'
  end
end

