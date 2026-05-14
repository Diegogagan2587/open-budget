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
    assert_select "div.fixed.right-4.z-40.md\\:hidden[data-controller='quick-add-menu']" # FAB on mobile
    assert_select "div.fixed.right-4.z-40.hidden.md\\:flex[data-controller='quick-add-menu']" # Toolbar on desktop
  end

  test "quick add links are present on dashboard" do
    get root_path
    assert_response :success
    assert_select "a[href='#{quick_add_financial_path}']"
  end
end
