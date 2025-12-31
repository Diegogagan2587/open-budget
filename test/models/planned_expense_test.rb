require "test_helper"

class PlannedExpenseTest < ActiveSupport::TestCase
  def setup
    @account = Account.create!(name: "Test Account")
    Current.account = @account

    @budget_period = BudgetPeriod.create!(
      name: "Test Period",
      start_date: Date.new(2025, 1, 1),
      end_date: Date.new(2025, 12, 31),
      account: @account
    )

    @income_event = IncomeEvent.create!(
      budget_period: @budget_period,
      description: "Test Income Event",
      expected_date: Date.new(2025, 1, 15),
      expected_amount: 1000.00,
      status: "pending",
      account: @account
    )

    @category = Category.create!(name: "Test Category", account: @account)
  end

  def teardown
    Current.account = nil
  end

  test "creating planned expense with spent status automatically creates expense" do
    planned_expense = PlannedExpense.create!(
      income_event: @income_event,
      category: @category,
      description: "Test: reassinged planned_expse from expese edit view",
      amount: 100.00,
      status: "spent"
    )

    # Reload to get the association
    planned_expense.reload

    # Should have created an expense
    assert planned_expense.expense.present?, "Expense should be created automatically"
    assert_equal 1, Expense.count, "Should have exactly one expense"

    expense = planned_expense.expense
    assert_equal planned_expense.amount, expense.amount
    assert_equal planned_expense.description, expense.description
    assert_equal planned_expense.category_id, expense.category_id
    assert_equal @income_event.id, expense.income_event_id
    assert_equal planned_expense.id, expense.planned_expense_id
    assert_equal @budget_period.id, expense.budget_period_id
  end

  test "creating planned expense with paid status automatically creates expense" do
    planned_expense = PlannedExpense.create!(
      income_event: @income_event,
      category: @category,
      description: "Test paid expense",
      amount: 50.00,
      status: "paid"
    )

    planned_expense.reload
    assert planned_expense.expense.present?, "Expense should be created automatically"
    assert_equal 1, Expense.count
  end

  test "creating planned expense with transferred status automatically creates expense" do
    planned_expense = PlannedExpense.create!(
      income_event: @income_event,
      category: @category,
      description: "Test transferred expense",
      amount: 75.00,
      status: "transferred"
    )

    planned_expense.reload
    assert planned_expense.expense.present?, "Expense should be created automatically"
    assert_equal 1, Expense.count
  end

  test "creating planned expense with other status does not create expense" do
    planned_expense = PlannedExpense.create!(
      income_event: @income_event,
      category: @category,
      description: "Test pending expense",
      amount: 25.00,
      status: "pending_to_pay"
    )

    assert_nil planned_expense.expense, "Expense should not be created for non-spent status"
    assert_equal 0, Expense.count
  end

  test "updating planned expense status to spent creates expense" do
    planned_expense = PlannedExpense.create!(
      income_event: @income_event,
      category: @category,
      description: "Test expense",
      amount: 100.00,
      status: "pending_to_pay"
    )

    assert_nil planned_expense.expense, "Should not have expense initially"
    assert_equal 0, Expense.count

    # Update status to spent
    planned_expense.update!(status: "spent")
    planned_expense.reload

    assert planned_expense.expense.present?, "Expense should be created when status changes to spent"
    assert_equal 1, Expense.count
  end

  test "updating planned expense status to spent does not create duplicate expense" do
    planned_expense = PlannedExpense.create!(
      income_event: @income_event,
      category: @category,
      description: "Test expense",
      amount: 100.00,
      status: "spent"
    )

    planned_expense.reload
    initial_expense_id = planned_expense.expense.id
    initial_count = Expense.count

    # Update status again (should not create duplicate)
    planned_expense.update!(status: "spent")
    planned_expense.reload

    assert_equal initial_expense_id, planned_expense.expense.id, "Should not create new expense"
    assert_equal initial_count, Expense.count, "Should not create duplicate expense"
  end

  test "apply! method still works correctly" do
    planned_expense = PlannedExpense.create!(
      income_event: @income_event,
      category: @category,
      description: "Test expense",
      amount: 100.00,
      status: "pending_to_pay"
    )

    assert_nil planned_expense.expense, "Should not have expense initially"

    planned_expense.apply!
    planned_expense.reload

    assert planned_expense.expense.present?, "Expense should be created by apply!"
    assert_equal "paid", planned_expense.status
    assert_equal 1, Expense.count
  end
end
