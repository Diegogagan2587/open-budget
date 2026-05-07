require "test_helper"

class Expenses::RecordExecutionServiceTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!(name: "Test Account")
    Current.account = @account

    @category = Category.create!(name: "Food", account: @account)
    @budget_period = BudgetPeriod.create!(
      name: "Period",
      start_date: Date.current.beginning_of_month,
      end_date: Date.current.end_of_month,
      account: @account
    )

    @asset_a = Financial::Asset.create!(
      account: @account,
      name: "Checking",
      account_type: "checking",
      status: "active",
      opening_balance: 1000
    )

    @asset_b = Financial::Asset.create!(
      account: @account,
      name: "Savings",
      account_type: "savings",
      status: "active",
      opening_balance: 100
    )

    @liability = Financial::Liability.create!(
      account: @account,
      name: "Card",
      liability_type: "credit_card",
      status: "active",
      opening_balance: 500
    )
  end

  def teardown
    Current.account = nil
  end

  test "creates transfer entry when destination is asset" do
    expense = Expense.new(
      account: @account,
      category: @category,
      budget_period: @budget_period,
      date: Date.current,
      amount: 50,
      description: "Move money"
    )

    result = Expenses::RecordExecutionService.call(
      expense: expense,
      source_selection: "asset:#{@asset_a.id}",
      destination_selection: "asset:#{@asset_b.id}"
    )

    assert result.success?
    assert_equal "transfer", result.entry.entry_type
    assert_equal @asset_a.id, result.entry.financial_account_id
    assert_equal @asset_b.id, result.entry.counterparty_financial_account_id
  end

  test "creates liability payment entry when destination is liability" do
    expense = Expense.new(
      account: @account,
      category: @category,
      budget_period: @budget_period,
      date: Date.current,
      amount: 25,
      description: "Pay card"
    )

    result = Expenses::RecordExecutionService.call(
      expense: expense,
      source_selection: "asset:#{@asset_a.id}",
      destination_selection: "liability:#{@liability.id}"
    )

    assert result.success?
    assert_equal "liability_payment", result.entry.entry_type
    assert_equal @asset_a.id, result.entry.financial_account_id
    assert_equal @liability.id, result.entry.financial_liability_id
  end

  test "creates liability charge when source is liability and destination blank" do
    expense = Expense.new(
      account: @account,
      category: @category,
      budget_period: @budget_period,
      date: Date.current,
      amount: 10,
      description: "Coca Cola"
    )

    result = Expenses::RecordExecutionService.call(
      expense: expense,
      source_selection: "liability:#{@liability.id}",
      destination_selection: ""
    )

    assert result.success?
    assert_equal "liability_charge", result.entry.entry_type
    assert_equal @liability.id, result.entry.financial_liability_id
  end
end
