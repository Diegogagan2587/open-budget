require "test_helper"

class Career::JobApplicationTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @user = users(:one)
    @company = Career::Company.create!(account: @account, name: "Acme")
  end

  test "validates status inclusion" do
    job_application = Career::JobApplication.new(
      account: @account,
      company: @company,
      role_title: "Rails Engineer",
      status: "invalid"
    )

    assert_not job_application.valid?
    assert_includes job_application.errors[:status], "is not included in the list"
  end

  test "has polymorphic associations" do
    job_application = Career::JobApplication.create!(
      account: @account,
      company: @company,
      role_title: "Ruby Developer",
      status: "saved"
    )

    task = Projects::Task.create!(
      account: @account,
      user: @user,
      title: "Follow up",
      status: "backlog",
      priority: "medium",
      taskable: job_application
    )

    assert_equal job_application, task.taskable
    assert_includes job_application.tasks, task
  end
end
