class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :account_memberships, dependent: :destroy
  has_many :accounts, through: :account_memberships

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validates :locale, inclusion: { in: %w[en es] }, allow_nil: true

  def owned_accounts
    accounts.joins(:account_memberships).where(account_memberships: { role: "owner" })
  end
end
