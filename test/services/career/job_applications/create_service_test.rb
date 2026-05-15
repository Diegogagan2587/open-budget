require "test_helper"

class Career::JobApplications::CreateServiceTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @user = users(:one)
  end

  test "creates company application and found event" do
    result = Career::JobApplications::CreateService.call(
      account: @account,
      user: @user,
      params: {
        company_name: "Example Corp",
        role_title: "Backend Engineer",
        status: "saved"
      }
    )

    assert result.success?
    assert_equal "Example Corp", result.job_application.company.name
    assert_equal "found", result.job_application.events.last.event_type
  end

  test "reuses existing company name case-insensitively" do
    existing = Career::Company.create!(account: @account, name: "Remote Inc")

    result = Career::JobApplications::CreateService.call(
      account: @account,
      user: @user,
      params: {
        company_name: "remote inc",
        role_title: "Rails Engineer",
        status: "saved"
      }
    )

    assert result.success?
    assert_equal existing.id, result.job_application.company.id
  end
end
