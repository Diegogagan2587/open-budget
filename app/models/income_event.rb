class IncomeEvent < ApplicationRecord
  belongs_to :account
  belongs_to :budget_period, optional: true
  has_many :planned_expenses, dependent: :destroy
  has_many :expenses, dependent: :nullify
  has_many :loan_payment_schedules, foreign_key: :loan_id, dependent: :destroy

  before_validation :set_account, on: :create
  before_validation :normalize_payment_frequency
  before_validation :apply_loan_defaults
  before_validation :infer_loan_interest_rate
  after_save :refresh_loan_payment_schedules, if: :loan?

  scope :for_account, ->(account) { where(account: account) }
  scope :regular, -> { where(income_type: "regular") }
  scope :loans, -> { where(income_type: "loan") }

  validates :expected_date, presence: true
  validates :expected_amount, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending received applied] }
  validates :income_type, presence: true, inclusion: { in: %w[regular loan] }
  validates :loan_amount, presence: true, numericality: { greater_than: 0 }, if: :loan?
  validates :number_of_payments, presence: true, numericality: { greater_than: 0, only_integer: true }, if: :loan?
  validates :payment_frequency, presence: true, inclusion: { in: %w[weekly biweekly quincenal monthly] }, if: :loan?
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :payment_amount, numericality: { greater_than: 0 }, allow_nil: true
  validate :loan_terms_present_for_calculation, if: :loan?
  validate :loan_payment_amount_consistency, if: :loan?

  scope :pending, -> { where(status: "pending") }
  scope :received, -> { where(status: "received") }
  scope :applied, -> { where(status: "applied") }
  scope :by_date, -> { order(expected_date: :desc) }

  def total_planned
    return loan_total_planned if loan?

    # Include:
    # 1. All planned expenses (they represent planned spending, even if applied)
    # 2. Expenses directly assigned (without a planned_expense_id)
    # Note: Expenses created from planned expenses (with planned_expense_id) are NOT counted
    # to avoid double-counting, as they're already represented by the planned expense
    planned_expenses.sum(:amount) + expenses.where(planned_expense_id: nil).sum(:amount)
  end

  def total_spent
    return loan_total_spent if loan?

    # Total of all expenses (both from planned and direct)
    expenses.sum(:amount)
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
    return if loan?

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
      [ event_effective_date, event.id ]
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

  def loan?
    income_type == "loan"
  end

  def regular?
    !loan?
  end

  def loan_payment_schedules_ordered
    loan_payment_schedules.ordered
  end

  def loan_total_repayment
    loan_payment_schedules.active.sum(:amount)
  end

  def loan_total_paid
    loan_payment_schedules.paid.sum(:amount)
  end

  def loan_remaining_balance
    loan_amount.to_d - loan_total_paid.to_d
  end

  def generate_loan_payment_schedules!(preserve_paid: true)
    if Rails.env.development?
      ::Loans.send(:remove_const, :ScheduleGenerator) if defined?(::Loans::ScheduleGenerator)
      load Rails.root.join("app/services/loans/schedule_generator.rb")
    elsif !defined?(::Loans::ScheduleGenerator)
      require Rails.root.join("app/services/loans/schedule_generator")
    end

    ::Loans::ScheduleGenerator.call(self, preserve_paid: preserve_paid)
  end

  def inferred_interest_rate?
    interest_rate_estimated
  end

  private

  def set_account
    self.account ||= Current.account if Current.account
  end

  def normalize_payment_frequency
    return if payment_frequency.blank?

    self.payment_frequency = "quincenal" if payment_frequency == "quicenal"
  end

  def apply_loan_defaults
    self.income_type ||= "regular"
    return unless loan?

    self.loan_amount ||= expected_amount
    self.expected_amount = loan_amount if loan_amount.present?
    self.expected_date ||= Date.current
    self.received_amount ||= loan_amount if received_amount.blank?
  end

  def infer_loan_interest_rate
    return unless loan?
    if interest_rate.present?
      self.interest_rate_estimated = false if will_save_change_to_interest_rate?
      return
    end
    return unless payment_amount.present? && number_of_payments.present? && loan_amount.present?

    self.interest_rate = inferred_annual_rate_from_payment
    self.interest_rate_estimated = true
  end

  def loan_total_planned
    loan_payment_schedules.active.sum(:amount)
  end

  def loan_total_spent
    loan_payment_schedules.paid.sum(:amount)
  end

  def refresh_loan_payment_schedules
    generate_loan_payment_schedules!
  end

  def loan_terms_present_for_calculation
    return if interest_rate.present? || payment_amount.present?

    errors.add(:base, "Provide interest rate or payment amount to build the loan schedule")
  end

  def loan_payment_amount_consistency
    return unless payment_amount.present? && number_of_payments.present? && loan_amount.present?
    return unless payment_amount.to_d * number_of_payments.to_i < loan_amount.to_d

    errors.add(:payment_amount, "is too low for the selected number of payments")
  end

  def inferred_annual_rate_from_payment
    periods_per_year = {
      "weekly" => 52.0,
      "biweekly" => 26.0,
      "quincenal" => (365.0 / 15.0),
      "monthly" => 12.0
    }.fetch(payment_frequency) { 12.0 }

    principal = loan_amount.to_d
    installment_amount = payment_amount.to_d
    periods = number_of_payments.to_i

    return 0.to_d if installment_amount * periods <= principal

    periodic_rate = solve_periodic_rate(principal: principal, payment_amount: installment_amount, periods: periods)
    (periodic_rate * periods_per_year * 100).round(3)
  end

  def solve_periodic_rate(principal:, payment_amount:, periods:)
    low = 0.0
    high = 1.0

    while payment_for_rate(principal: principal, rate: high, periods: periods) < payment_amount
      high *= 2
      break if high > 100
    end

    80.times do
      mid = (low + high) / 2.0
      computed_payment = payment_for_rate(principal: principal, rate: mid, periods: periods)

      if computed_payment < payment_amount
        low = mid
      else
        high = mid
      end
    end

    ((low + high) / 2.0).to_d
  end

  def payment_for_rate(principal:, rate:, periods:)
    return principal / periods if rate.zero?

    numerator = principal * rate
    denominator = 1 - (1 + rate)**(-periods)
    numerator / denominator
  end
end
