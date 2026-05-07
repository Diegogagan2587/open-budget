require "test_helper"

class DashboardIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.accounts.first || @user.accounts.create!(name: "Test Account")
    sign_in_as(@user, @account)
  end

  test "dashboard renders quick-add menu component" do
    get root_path
    assert_response :success
    assert_select "div.fixed.bottom-6.right-6.z-40" # FAB on mobile
    assert_select "div.hidden.md\\:flex" # Toolbar on desktop
  end

  test "quick add links are present on dashboard" do
    get root_path
    assert_response :success
    assert_select "a[href='#{quick_add_financial_path}']"
  end
end
