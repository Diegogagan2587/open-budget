module Projects
  class Project < ApplicationRecord
    STATUSES = %w[pending active completed archived].freeze
    PRIORITIES = %w[low medium high].freeze

    belongs_to :account
    belongs_to :user, foreign_key: :owner_id
    has_many :tasks, dependent: :destroy
    has_many :project_docs, dependent: :destroy
    has_many :docs, through: :project_docs
    has_many :project_links, dependent: :destroy
    has_many :links, through: :project_links
    has_many :project_meetings, dependent: :destroy, class_name: "Projects::ProjectMeeting"
    has_many :meetings, through: :project_meetings, class_name: "Projects::Meeting"

    before_create :set_account

    validates :name, presence: true, uniqueness: { scope: :account_id }
    validates :status, inclusion: { in: STATUSES }
    validates :priority, inclusion: { in: PRIORITIES }

    scope :for_account, ->(account) { where(account_id: account.id) }

    def completion_percentage
      return 0 if tasks.empty?

      completed_count = tasks.where(status: "done").count
      (completed_count.to_f / tasks.count * 100).round(2)
    end

    private

    def set_account
      self.account = Current.account if account.nil?
    end
  end
end
