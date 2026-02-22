module Projects
  class TaskRowComponent < ViewComponent::Base
    def initialize(task:, project: nil)
      @task = task
      @project = project
    end

    attr_reader :task, :project
  end
end
