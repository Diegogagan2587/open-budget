require "test_helper"

class SettingsFinanceNavigationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @account = accounts(:one)
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

  test "main navbar does not include categories link" do
    sign_in

    get root_path

    assert_response :success
    assert_select "header nav a", text: I18n.t("nav.categories"), count: 0
  end

  test "settings finance section links to categories management" do
    sign_in

    get edit_settings_path(section: "finance")

    assert_response :success
    assert_select "h2", text: I18n.t("settings.finance.title")
    assert_select "a[href='#{settings_finance_categories_path}']", text: I18n.t("settings.finance.manage_categories")
  end
end
