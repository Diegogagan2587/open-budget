module Projects
  class TaskDoc < ApplicationRecord
    belongs_to :task, class_name: "Projects::Task"
    belongs_to :doc, class_name: "Projects::Doc"

    validates :task_id, uniqueness: { scope: :doc_id }
  end
end
