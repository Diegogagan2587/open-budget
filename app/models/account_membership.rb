class AccountMembership < ApplicationRecord
  belongs_to :user
  belongs_to :account

  validates :role, presence: true, inclusion: { in: %w[owner member] }
  validates :user_id, uniqueness: { scope: :account_id }

  scope :owners, -> { where(role: "owner") }
  scope :members, -> { where(role: "member") }

  def owner?
    role == "owner"
  end
end
