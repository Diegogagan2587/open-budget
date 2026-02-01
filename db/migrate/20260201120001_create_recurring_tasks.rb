# frozen_string_literal: true

class CreateRecurringTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :recurring_tasks do |t|
      t.references :account, null: false, foreign_key: true
      t.references :task_area, null: true, foreign_key: true
      t.string :name, null: false
      t.string :recurrence, null: false, default: "none"
      t.date :next_due_date
      t.datetime :last_done_at
      t.text :notes
      t.integer :position

      t.timestamps
    end
  end
end
