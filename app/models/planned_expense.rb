class PlannedExpense < ApplicationRecord
  belongs_to :account
  belongs_to :income_event
  belongs_to :category
  belongs_to :expense_template, optional: true
  has_one :expense, dependent: :nullify

  before_validation :set_account, on: :create

  scope :for_account, ->(account) { where(account: account) }

  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  scope :by_position, -> { order(:position, :created_at) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_template, ->(template_id) { where(expense_template_id: template_id) }

  # Automatically create expense when status is set to spent/paid/transferred
  after_create :create_expense_if_spent_on_create
  after_update :create_expense_if_spent_on_update, if: :saved_change_to_status?

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
      budget_period_id: budget_period_id,
      income_event_id: income_event.id,
      planned_expense_id: id,
      account_id: account_id
    )
    update!(status: "paid") unless status == "paid"
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

  private

  def set_account
    self.account ||= Current.account if Current.account
  end

  def create_expense_if_spent_on_create
    # Create expense if status is spent/paid/transferred on creation
    create_expense_if_spent
  end

  def create_expense_if_spent_on_update
    # Create expense if status changed to spent/paid/transferred on update
    create_expense_if_spent
  end

  def create_expense_if_spent
    # Only create expense if status is spent/paid/transferred and expense doesn't exist
    # Check database directly to avoid association caching issues
    if %w[spent paid transferred].include?(status) && !Expense.exists?(planned_expense_id: id)
      budget_period_id = income_event.budget_period_id
      Expense.create!(
        date: Date.current,
        amount: amount,
        description: description,
        category_id: category_id,
        budget_period_id: budget_period_id,
        income_event_id: income_event.id,
        planned_expense_id: id
      )
    end
  end
end
