class CreateProjectMeetings < ActiveRecord::Migration[8.0]
  def change
    create_table :project_meetings do |t|
      t.references :project, null: false, foreign_key: true
      t.references :meeting, null: false, foreign_key: true

      t.timestamps
    end

    add_index :project_meetings, [:project_id, :meeting_id], unique: true
  end
end
