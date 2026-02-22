module Projects
  class Link < ApplicationRecord
    LINK_TYPES = %w[reference resource documentation].freeze

    belongs_to :account
    has_many :project_links, dependent: :destroy
    has_many :projects, through: :project_links

    before_create :set_account

    validates :title, presence: true
    validates :url, presence: true, uniqueness: { scope: :account_id }
    validates :link_type, inclusion: { in: LINK_TYPES }

    scope :for_account, ->(account) { where(account_id: account.id) }

    private

    def set_account
      self.account = Current.account if account.nil?
    end
  end
end
