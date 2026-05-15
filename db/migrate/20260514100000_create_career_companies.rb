class CreateCareerCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :career_companies do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :website_url
      t.string :linkedin_url
      t.text :notes

      t.timestamps
    end

    add_index :career_companies, [:account_id, :name]
  end
end
