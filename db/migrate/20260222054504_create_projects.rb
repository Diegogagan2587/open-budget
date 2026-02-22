class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :account, null: false, foreign_key: true
      t.bigint :owner_id, null: false
      t.string :name, null: false
      t.text :summary
      t.string :status, default: "pending", null: false
      t.string :priority, default: "medium", null: false
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_index :projects, [ :account_id, :name ], unique: true
    add_foreign_key :projects, :users, column: :owner_id, primary_key: :id
  end
end
