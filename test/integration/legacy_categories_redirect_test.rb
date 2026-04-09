require "test_helper"

class LegacyCategoriesRedirectTest < ActionDispatch::IntegrationTest
  test "legacy categories index redirects to finance namespace" do
    get "/categories"

    assert_response :redirect
    assert_redirected_to settings_finance_categories_path
  end

  test "legacy categories new redirects to finance namespace" do
    get "/categories/new"

    assert_response :redirect
    assert_redirected_to new_settings_finance_category_path
  end

  test "legacy categories show redirects to finance namespace" do
    category = categories(:one)

    get "/categories/#{category.id}"

    assert_response :redirect
    assert_redirected_to settings_finance_category_path(category)
  end

  test "legacy categories edit redirects to finance namespace" do
    category = categories(:one)

    get "/categories/#{category.id}/edit"

    assert_response :redirect
    assert_redirected_to edit_settings_finance_category_path(category)
  end
end
