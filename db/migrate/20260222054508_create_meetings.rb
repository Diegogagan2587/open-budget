class CreateMeetings < ActiveRecord::Migration[8.0]
  def change
    create_table :meetings do |t|
      t.references :account, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.string :meeting_url
      t.string :location

      t.timestamps
    end

    add_index :meetings, [:account_id, :title]
    add_index :meetings, :start_time
  end
end
