class BudgetPeriod < ApplicationRecord
  has_many :income_events, dependent: :nullify
  has_many :planned_expenses, through: :income_events
  has_many :budget_line_items, dependent: :destroy
  has_many :expenses, dependent: :nullify

  def total_income
    income_events.sum { |ie| ie.received_amount || ie.expected_amount }
  end

  def total_planned
    planned_expenses.sum(:amount)
  end

  def remaining_budget
    total_income - total_planned
  end

  def income_events_ordered
    income_events.order(:expected_date)
  end
end

