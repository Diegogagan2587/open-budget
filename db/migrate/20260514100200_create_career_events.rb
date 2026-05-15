class CreateCareerEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :career_events do |t|
      t.references :account, null: false, foreign_key: true
      t.references :career_job_application, null: false, foreign_key: true

      t.string :event_type, null: false
      t.datetime :occurred_at, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :career_events, [:account_id, :event_type]
    add_index :career_events, [:career_job_application_id, :occurred_at]
  end
end
