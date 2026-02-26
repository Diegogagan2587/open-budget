class Projects::DocTag < ApplicationRecord
  self.table_name = 'doc_tags'

  belongs_to :doc, class_name: 'Projects::Doc'
  belongs_to :tag

  validates :doc_id, uniqueness: { scope: :tag_id }
end
