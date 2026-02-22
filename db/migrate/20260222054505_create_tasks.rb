class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.bigint :owner_id, null: false
      t.string :title, null: false
      t.text :description
      t.string :task_number, null: false
      t.string :status, default: "backlog", null: false
      t.string :priority, default: "medium", null: false
      t.date :due_date
      t.datetime :completed_at

      t.timestamps
    end

    add_index :tasks, [ :account_id, :task_number ], unique: true
    add_index :tasks, [ :project_id, :task_number ], unique: true
    add_index :tasks, :status
    add_index :tasks, :priority
    add_foreign_key :tasks, :users, column: :owner_id, primary_key: :id
  end
end
