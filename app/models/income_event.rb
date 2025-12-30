class IncomeEvent < ApplicationRecord
  belongs_to :account
  belongs_to :budget_period, optional: true
  has_many :planned_expenses, dependent: :destroy

  before_validation :set_account, on: :create

  scope :for_account, ->(account) { where(account: account) }

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

    # Find previous event: the one with the highest effective date that is still before current
    # Effective date = received_date if present, otherwise expected_date
    # Load all events and calculate in Ruby for clarity and correctness
    candidates = budget_period.income_events.where.not(id: current_id).to_a
    
    # Calculate effective date for current event
    current_effective_date = current_date
    
    # Find all events that come before current (by effective date)
    previous_events = candidates.select do |event|
      event_effective_date = event.received_date || event.expected_date
      event_effective_date < current_effective_date || 
        (event_effective_date == current_effective_date && event.id < current_id)
    end
    
    return nil if previous_events.empty?
    
    # Return the one with the highest effective date (most recent before current)
    previous_events.max_by do |event|
      event_effective_date = event.received_date || event.expected_date
      [event_effective_date, event.id]
    end
  end

  def previous_balance
    prev = previous_income_event
    return 0.0 unless prev

    # Use effective_remaining_budget to account for cumulative carryover
    # This ensures that if the previous event itself had a previous balance,
    # we carry forward the complete effective balance
    prev.effective_remaining_budget
  end

  def effective_remaining_budget
    # If previous_balance is negative (deficit), it reduces available budget
    # If previous_balance is positive (surplus), it increases available budget
    remaining_budget + previous_balance
  end

  private

  def set_account
    self.account ||= Current.account if Current.account
  end
end
