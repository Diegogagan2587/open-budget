require "test_helper"

class Career::JobApplications::UpdateStatusServiceTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @user = users(:one)
    @company = Career::Company.create!(account: @account, name: "Status Co")
    @job_application = Career::JobApplication.create!(
      account: @account,
      company: @company,
      role_title: "Fullstack",
      status: "saved"
    )
  end

  test "changes status and creates event" do
    result = Career::JobApplications::UpdateStatusService.call(
      job_application: @job_application,
      actor: @user,
      params: { status: "applied" }
    )

    assert result.success?
    assert_equal "applied", @job_application.reload.status
    assert @job_application.applied_on.present?
    assert_equal "applied", @job_application.events.last.event_type
  end
end
