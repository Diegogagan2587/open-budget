require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @account = accounts(:one)
    @category = categories(:one)

    @budget_period = BudgetPeriod.create!(
      name: "March Budget",
      period_type: "monthly",
      start_date: Date.current.beginning_of_month,
      end_date: Date.current.end_of_month,
      total_amount: 5000,
      account: @account
    )

    @income_event = IncomeEvent.create!(
      description: "Salary",
      expected_date: Date.current,
      expected_amount: 3200,
      status: "pending",
      account: @account,
      budget_period: @budget_period
    )
  end

  def sign_in
    post session_path, params: {
      email_address: @user.email_address,
      password: "password"
    }
    Current.account = @account
  end

  def teardown
    Current.account = nil
    Current.session = nil
  end

  test "income event show displays quick add direct expense button" do
    sign_in

    get income_event_path(@income_event)

    assert_response :success
    assert_select "a[href='#{income_event_new_direct_expense_path(@income_event)}']", text: /Add Unplanned Expense/
  end

  test "should get quick new direct expense with defaults" do
    sign_in

    get income_event_new_direct_expense_path(@income_event)

    assert_response :success
    assert_select "h1", /Quick Add Direct Expense/
    assert_select "form[action='#{income_event_direct_expenses_path(@income_event)}']"
    assert_select "input[name='expense[date]'][value='#{Date.current}']"
    assert_select "select[name='expense[budget_period_id]'] option[selected][value='#{@budget_period.id}']"
    assert_select "p", text: /Salary/
  end

  test "should create quick direct expense for selected income event" do
    sign_in

    assert_difference("Expense.count", 1) do
      post income_event_direct_expenses_path(@income_event), params: {
        expense: {
          amount: 48.75,
          date: Date.current,
          category_id: @category.id,
          budget_period_id: @budget_period.id,
          description: "Taxi"
        }
      }
    end

    expense = Expense.order(:created_at).last
    assert_equal @income_event.id, expense.income_event_id
    assert_equal @budget_period.id, expense.budget_period_id
    assert_equal @account.id, expense.account_id
    assert_redirected_to income_event_path(@income_event)
  end

  test "invalid quick direct expense re-renders quick form" do
    sign_in

    assert_no_difference("Expense.count") do
      post income_event_direct_expenses_path(@income_event), params: {
        expense: {
          amount: nil,
          date: Date.current,
          category_id: nil,
          budget_period_id: nil,
          description: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "h1", /Quick Add Direct Expense/
    assert_select "form[action='#{income_event_direct_expenses_path(@income_event)}']"
  end
end
