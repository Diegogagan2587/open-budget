class ProjectMeeting < ApplicationRecord
  belongs_to :project, class_name: "Projects::Project"
  belongs_to :meeting
end
