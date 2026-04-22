class LoanPaymentSchedule < ApplicationRecord
  belongs_to :account
  belongs_to :loan, class_name: "IncomeEvent"

  before_validation :set_account, on: :create

  scope :for_account, ->(account) { where(account: account) }
  scope :scheduled, -> { where(status: "scheduled") }
  scope :paid, -> { where(status: "paid") }
  scope :overdue, -> { where(status: "overdue") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :active, -> { where.not(status: "cancelled") }
  scope :ordered, -> { order(:due_date, :installment_number) }

  validates :due_date, presence: true
  validates :installment_number, presence: true, numericality: { greater_than: 0 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[scheduled paid overdue cancelled] }

  def paid?
    status == "paid"
  end

  def scheduled?
    status == "scheduled"
  end

  def overdue?
    status == "overdue"
  end

  def mark_paid!(paid_at: Date.current)
    update!(status: "paid", paid_at: paid_at)
  end

  private

  def set_account
    self.account ||= Current.account if Current.account
  end
end
