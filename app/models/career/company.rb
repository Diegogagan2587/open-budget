module Career
  class Company < ApplicationRecord
    belongs_to :account

    has_many :job_applications,
      class_name: "Career::JobApplication",
      foreign_key: :career_company_id,
      dependent: :destroy,
      inverse_of: :company

    validates :name, presence: true

    scope :for_account, ->(account) { where(account_id: account.id) }
  end
end
