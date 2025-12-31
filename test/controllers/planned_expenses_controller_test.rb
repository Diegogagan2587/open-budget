require "test_helper"

class PlannedExpensesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @income_event = income_events(:one)
    @category = categories(:one)
  end

  test "should get new" do
    get new_income_event_planned_expense_path(@income_event)
    assert_response :success
    assert_select "h1", "New Planned Expense"
    assert_select "form"
  end

  test "new action should load income events for assignment" do
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
    get new_income_event_planned_expense_path(@income_event)
    assert_response :success

    # Verify template selection section is present
    assert_select "h3", text: /Template Selection/
  end

  test "should create planned expense" do
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
end
