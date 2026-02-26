class AddAuthorAndTagsToDocsAndCreateTags < ActiveRecord::Migration[8.0]
  def change
    # Add created_by_id to docs table
    add_column :docs, :created_by_id, :bigint, null: true
    add_index :docs, :created_by_id
    add_foreign_key :docs, :users, column: :created_by_id, on_delete: :nullify

    # Create tags table
    create_table :tags do |t|
      t.bigint :account_id, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    add_index :tags, :account_id
    add_index :tags, [:account_id, :name], unique: true
    add_foreign_key :tags, :accounts, on_delete: :cascade

    # Create doc_tags junction table
    create_table :doc_tags do |t|
      t.bigint :doc_id, null: false
      t.bigint :tag_id, null: false

      t.timestamps
    end
    add_index :doc_tags, :doc_id
    add_index :doc_tags, :tag_id
    add_index :doc_tags, [:doc_id, :tag_id], unique: true
    add_foreign_key :doc_tags, :docs, on_delete: :cascade
    add_foreign_key :doc_tags, :tags, on_delete: :cascade
  end
end
