class IncomeEvent < ApplicationRecord
  belongs_to :budget_period, optional: true
  has_many :planned_expenses, dependent: :destroy

  validates :expected_date, presence: true
  validates :expected_amount, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending received applied] }

  scope :pending, -> { where(status: "pending") }
  scope :received, -> { where(status: "received") }
  scope :applied, -> { where(status: "applied") }
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
      status: "received"
    )
  end

  def apply_all!
    planned_expenses.where.not(status: %w[paid transferred spent]).find_each do |planned_expense|
      planned_expense.apply!
    end
    update!(status: "applied")
  end

  def is_received?
    received_date.present?
  end

  def is_applied?
    status == "applied"
  end

  def previous_income_event
    return nil unless budget_period_id

    # Get the date to use for ordering: received_date if present, otherwise expected_date
    current_date = received_date || expected_date
    current_id = id

    # Find previous event: ordered by received_date if present, otherwise expected_date
    # Use COALESCE to handle NULL received_date values
    previous = budget_period.income_events
      .where.not(id: current_id)
      .where(
        "(COALESCE(received_date, expected_date) < ?) OR (COALESCE(received_date, expected_date) = ? AND id < ?)",
        current_date, current_date, current_id
      )
      .order(
        Arel.sql("COALESCE(received_date, expected_date) DESC, id DESC")
      )
      .first

    previous
  end

  def previous_balance
    prev = previous_income_event
    return 0.0 unless prev

    prev.remaining_budget
  end

  def effective_remaining_budget
    # If previous_balance is negative (deficit), it reduces available budget
    # If previous_balance is positive (surplus), it increases available budget
    remaining_budget + previous_balance
  end
end
