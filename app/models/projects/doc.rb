module Projects
  class Doc < ApplicationRecord
    DOC_TYPES = %w[file note].freeze

    belongs_to :account
    has_many :project_docs, dependent: :destroy
    has_many :projects, through: :project_docs
    has_many :doc_links, dependent: :destroy
    has_many :links, through: :doc_links

    before_create :set_account

    validates :title, presence: true, uniqueness: { scope: :account_id }
    validates :doc_type, inclusion: { in: DOC_TYPES }

    scope :for_account, ->(account) { where(account_id: account.id) }

    private

    def set_account
      self.account = Current.account if account.nil?
    end
  end
end
