require "test_helper"

class SidebarLayoutRenderTest < ActionDispatch::IntegrationTest
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

  test "authenticated finance page renders sidebar layout" do
    sign_in

    get finance_path

    assert_response :success
    assert_select "div[data-controller='sidebar']", count: 1
    assert_select "aside[data-slot='sidebar']", count: 1
    assert_select "div[data-sidebar-target='panel']", count: 1
    assert_select "a[href='#{finance_path}'].font-semibold.text-gray-900", count: 1
  end
end
