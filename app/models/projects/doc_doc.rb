module Projects
  class DocDoc < ApplicationRecord
    belongs_to :doc, class_name: "Projects::Doc"
    belongs_to :related_doc, class_name: "Projects::Doc"

    validates :doc_id, uniqueness: { scope: :related_doc_id }
    validate :prevent_self_reference

    private

    def prevent_self_reference
      errors.add(:related_doc_id, "cannot reference itself") if doc_id == related_doc_id
    end
  end
end
