module Projects
  class ProjectDoc < ApplicationRecord
    belongs_to :project
    belongs_to :doc
  end
end
