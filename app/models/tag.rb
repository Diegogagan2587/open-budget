class Tag < ApplicationRecord
  belongs_to :account
  has_many :doc_tags, dependent: :destroy
  has_many :docs, through: :doc_tags

  validates :name, presence: true, uniqueness: { scope: :account_id }
end
