require "test_helper"

class PlannedExpensesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @account = accounts(:one)
    @income_event = income_events(:one)
    @category = categories(:one)

    # Create session for authentication
    @session = @user.sessions.create!(
      user_agent: "Test Agent",
      ip_address: "127.0.0.1"
    )
  end

  # Helper to sign in by making a request to the sessions controller
  # This properly sets up the session cookie
  def sign_in
    # First, ensure the user has a password set in fixtures
    # Then sign in through the sessions controller
    post session_path, params: {
      email_address: @user.email_address,
      password: "password"  # From fixtures
    }
    # After signing in, set Current.account
    Current.account = @account
  end

  def teardown
    Current.account = nil
    Current.session = nil
  end

  test "should get new" do
    sign_in
    get new_income_event_planned_expense_path(@income_event)
    assert_response :success
    assert_select "h1", "New Planned Expense"
    assert_select "form"
  end

  test "new action should load income events for assignment" do
    sign_in
    get new_income_event_planned_expense_path(@income_event)
    assert_response :success

    # Verify the form includes income event assignment section
    assert_select "h3", text: /Income Event Assignment/

    # Verify income events dropdown is present
    assert_select "select[name='planned_expense[income_event_id]']"

    # Verify at least the current income event is in the options
    assert_select "select[name='planned_expense[income_event_id]'] option[value='#{@income_event.id}']"
  end

  test "new action should load expense templates" do
    sign_in
    get new_income_event_planned_expense_path(@income_event)
    assert_response :success

    # Verify template selection section is present
    assert_select "h3", text: /Template Selection/
  end

  test "should create planned expense" do
    sign_in
    assert_difference("PlannedExpense.count") do
      post income_event_planned_expenses_path(@income_event), params: {
        planned_expense: {
          category_id: @category.id,
          description: "Test Expense",
          amount: 100.00,
          status: "pending_to_pay"
        }
      }
    end

    assert_redirected_to income_event_planned_expenses_path(@income_event)
  end

  test "should not create planned expense with invalid data" do
    sign_in
    assert_no_difference("PlannedExpense.count") do
      post income_event_planned_expenses_path(@income_event), params: {
        planned_expense: {
          category_id: nil,
          description: "",
          amount: nil,
          status: ""
        }
      }
    end

    assert_response :unprocessable_entity
    # Verify form is re-rendered with income_events available
    assert_select "select[name='planned_expense[income_event_id]']"
  end

  test "edit form shows current amount and edit mode for template selector" do
    sign_in
    planned_expense = PlannedExpense.create!(
      income_event: @income_event,
      category: @category,
      account: @account,
      description: "Rent",
      amount: 250.50,
      status: "pending_to_pay"
    )

    get edit_income_event_planned_expense_path(@income_event, planned_expense)
    assert_response :success
    assert_select "h1", "Edit Planned Expense"

    # Amount field must show the current value (not a placeholder) so the template-selector
    # controller preserves it when editing
    assert_select "input[name='planned_expense[amount]']" do |inputs|
      assert_equal 1, inputs.size, "Expected one amount input"
      value = inputs.first["value"]
      assert value.present?, "Amount input should have a value when editing"
      assert_in_delta 250.50, value.to_f, 0.01, "Amount input should show the current planned expense amount"
    end

    # Form must signal edit mode so the template-selector JS does not clear the amount
    assert_select "form[data-template-selector-edit-mode-value='true']", 1,
      "Edit form should have edit mode so amount is preserved"
  end
end
