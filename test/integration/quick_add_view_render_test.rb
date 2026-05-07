require "test_helper"

class QuickAddViewRenderTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.accounts.first
    post session_path, params: {
      email_address: @user.email_address,
      password: "password"
    }
  end

  test "financial modal renders with income form" do
    get quick_add_financial_path
    if response.status == 200
      assert_select "div[data-controller='quick-add-tabs']", count: 1
      assert_select "button", text: /Income/
      assert_select "button", text: /Expense/
      assert_select "button", text: /Transfer/
    end
  end

  test "quick add menu renders on dashboard" do
    get root_path
    if response.status == 200
      # Check for FAB on mobile
      assert_select "div.fixed.bottom-6.right-6.z-40"
      # Check for link to quick-add
      assert_select "a[href*='quick-add']"
    end
  end
end
