class CreateProjectDocs < ActiveRecord::Migration[8.0]
  def change
    create_table :project_docs do |t|
      t.references :project, null: false, foreign_key: true
      t.references :doc, null: false, foreign_key: true

      t.timestamps
    end

    add_index :project_docs, [ :project_id, :doc_id ], unique: true
  end
end
