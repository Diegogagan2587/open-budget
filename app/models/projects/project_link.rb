module Projects
  class ProjectLink < ApplicationRecord
    belongs_to :project
    belongs_to :link
  end
end
