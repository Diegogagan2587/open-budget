module Projects
  class ProjectRowComponent < ViewComponent::Base
    def initialize(project:)
      @project = project
    end

    attr_reader :project

    def completion_percentage
      project.completion_percentage
    end
  end
end
