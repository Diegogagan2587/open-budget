class Expense < ApplicationRecord
  attr_accessor :source_selection, :destination_selection

  belongs_to :account
  belongs_to :category
  belongs_to :budget_period
  belongs_to :income_event, optional: true
  belongs_to :loan, class_name: "IncomeEvent", optional: true
  belongs_to :financial_account, class_name: "Financial::Asset", optional: true
  belongs_to :financial_liability, class_name: "Financial::Liability", optional: true
  belongs_to :counterparty_financial_account, class_name: "Financial::Asset", optional: true
  belongs_to :counterparty_financial_liability, class_name: "Financial::Liability", optional: true
  belongs_to :planned_expense, optional: true
  has_one :financial_entry, class_name: "Financial::Entry", inverse_of: :expense, dependent: :destroy
  has_one :shopping_item, dependent: :nullify

  before_validation :set_account, on: :create
  after_destroy :restore_planned_expense_status

  scope :for_account, ->(account) { where(account: account) }

  validate :financial_routing_is_valid

  private

  def set_account
    self.account ||= Current.account if Current.account
  end

  public

  def source_selection
    @source_selection || selection_for_source
  end

  def source_selection=(value)
    @source_selection = value.presence
    assign_source_selection(value)
  end

  def destination_selection
    @destination_selection || selection_for_destination
  end

  def destination_selection=(value)
    @destination_selection = value.presence
    assign_destination_selection(value)
  end

  def transfer?
    financial_account.present? && counterparty_financial_account.present?
  end

  def debt_payment?
    financial_account.present? && counterparty_financial_liability.present?
  end

  private

  def assign_source_selection(value)
    return if value.blank?

    kind, id = value.split(":", 2)
    case kind
    when "asset"
      self.financial_account_id = id
      self.financial_liability_id = nil
    when "liability"
      self.financial_liability_id = id
      self.financial_account_id = nil
    end
  end

  def assign_destination_selection(value)
    return unless counterparty_routing_columns_available?
    return clear_destination_selection if value.blank?

    kind, id = value.split(":", 2)
    case kind
    when "asset"
      self.counterparty_financial_account = Financial::Asset.for_account(account).find_by(id: id)
      self.counterparty_financial_liability = nil
    when "liability"
      self.counterparty_financial_liability = Financial::Liability.for_account(account).find_by(id: id)
      self.counterparty_financial_account = nil
    end
  end

  def clear_destination_selection
    return unless counterparty_routing_columns_available?

    self.counterparty_financial_account = nil
    self.counterparty_financial_liability = nil
  end

  def selection_for_source
    return "asset:#{financial_account_id}" if financial_account.present?
    return "liability:#{financial_liability_id}" if financial_liability.present?

    nil
  end

  def selection_for_destination
    return nil unless counterparty_routing_columns_available?

    return "asset:#{counterparty_financial_account_id}" if counterparty_financial_account.present?
    return "liability:#{counterparty_financial_liability_id}" if counterparty_financial_liability.present?

    nil
  end

  def financial_routing_is_valid
    if financial_account.blank? && financial_liability.blank?
      errors.add(:source_selection, "must be selected")
      return
    end

    if financial_account.present? && financial_liability.present?
      errors.add(:base, "Select either an asset account or a liability account, not both")
    end

    if financial_liability.present? && destination_selection.present?
      errors.add(:destination_selection, "must be blank when the source is a liability")
    end

    if counterparty_routing_columns_available? && counterparty_financial_account.present? && counterparty_financial_liability.present?
      errors.add(:destination_selection, "must select only one destination account")
    end

    if counterparty_routing_columns_available? && financial_account.present? && counterparty_financial_account.present? && financial_account_id == counterparty_financial_account_id
      errors.add(:counterparty_financial_account, "must be different from source account")
    end

    if financial_account.present? && financial_account.account_id != account_id
      errors.add(:financial_account, "must belong to the current account")
    end

    if financial_liability.present? && financial_liability.account_id != account_id
      errors.add(:financial_liability, "must belong to the current account")
    end

    if counterparty_routing_columns_available? && counterparty_financial_account.present? && counterparty_financial_account.account_id != account_id
      errors.add(:counterparty_financial_account, "must belong to the current account")
    end

    if counterparty_routing_columns_available? && counterparty_financial_liability.present? && counterparty_financial_liability.account_id != account_id
      errors.add(:counterparty_financial_liability, "must belong to the current account")
    end
  end

  def counterparty_routing_columns_available?
    self.class.column_names.include?("counterparty_financial_account_id") &&
      self.class.column_names.include?("counterparty_financial_liability_id")
  end

  def restore_planned_expense_status
    return unless planned_expense.present?

    planned_expense.update!(status: "pending_to_pay")
  end
end
