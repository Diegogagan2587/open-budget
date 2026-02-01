# frozen_string_literal: true

class CreateTaskAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :task_areas do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :task_areas, [ :account_id, :name ], unique: true
  end
end
