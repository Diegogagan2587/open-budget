class CreateCareerJobApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :career_job_applications do |t|
      t.references :account, null: false, foreign_key: true
      t.references :career_company, null: false, foreign_key: true

      t.string :role_title, null: false
      t.text :job_url
      t.string :source
      t.string :status, null: false, default: "saved"
      t.date :found_on
      t.date :applied_on
      t.integer :salary_min
      t.integer :salary_max
      t.string :currency, null: false, default: "USD"
      t.string :remote_type
      t.string :location
      t.integer :priority, null: false, default: 0
      t.integer :fit_score
      t.text :job_description
      t.text :notes

      t.timestamps
    end

    add_index :career_job_applications, [:account_id, :status]
    add_index :career_job_applications, [:account_id, :found_on]
    add_index :career_job_applications, [:account_id, :applied_on]
  end
end
