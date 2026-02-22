module Projects
  class DocLink < ApplicationRecord
    belongs_to :doc, class_name: "Projects::Doc"
    belongs_to :link, class_name: "Projects::Link"

    validates :doc_id, uniqueness: { scope: :link_id }
  end
end
