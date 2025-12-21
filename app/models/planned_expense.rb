class PlannedExpense < ApplicationRecord
  belongs_to :income_event
  belongs_to :category
  belongs_to :expense_template, optional: true

  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  scope :by_position, -> { order(:position, :created_at) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_template, ->(template_id) { where(expense_template_id: template_id) }

  def percentage_of_income
    return 0 if income_event.expected_amount.zero?
    (amount / income_event.expected_amount) * 100
  end

  def apply!
    budget_period_id = income_event.budget_period_id
    Expense.create!(
      date: Date.current,
      amount: amount,
      description: description,
      category_id: category_id,
      budget_period_id: budget_period_id
    )
    update!(status: 'paid') unless status == 'paid'
  end

  def template_progress
    return nil unless expense_template

    saved = expense_template.total_saved
    total = expense_template.total_amount
    percentage = expense_template.progress_percentage

    {
      saved: saved,
      total: total,
      percentage: percentage,
      remaining: expense_template.remaining_amount,
      complete: expense_template.is_complete?
    }
  end
end

