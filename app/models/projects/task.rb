module Projects
  class Task < ApplicationRecord
    STATUSES = %w[backlog planning in_progress paused done canceled].freeze
    PRIORITIES = %w[low medium high].freeze

    belongs_to :project
    belongs_to :account
    belongs_to :user, foreign_key: :owner_id
    has_many :project_docs, dependent: :destroy
    has_many :project_links, dependent: :destroy
    has_many :project_meetings, dependent: :destroy

    before_create :set_account_and_task_number

    validates :title, presence: true
    validates :task_number, uniqueness: { scope: :account_id, allow_nil: true }
    validates :status, inclusion: { in: STATUSES }
    validates :priority, inclusion: { in: PRIORITIES }
    validates :project_id, presence: true

    scope :for_account, ->(account) { where(account_id: account.id) }
    scope :pending, -> { where(status: %w[backlog planning in_progress paused]) }
    scope :completed, -> { where(status: %w[done canceled]) }
    scope :by_status, ->(status) { where(status: status) if status.present? }
    scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }

    def status_label
      I18n.t("tasks.status.#{status}", default: status)
    end

    def priority_label
      I18n.t("tasks.priority.#{priority}", default: priority)
    end

    private

    def set_account_and_task_number
      self.account = Current.account if account.nil?
      generate_task_number
    end

    def generate_task_number
      return if task_number.present?

      current_acc = account || Current.account
      last_task = Task.where(account_id: current_acc.id).order(created_at: :desc).first
      next_number = if last_task
                      last_task.task_number.match(/\d+/)&.to_s&.to_i.to_i + 1
      else
                      1
      end
      self.task_number = "TASK-#{next_number}"
    end
  end
end
