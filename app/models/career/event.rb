module Career
  class Event < ApplicationRecord
    EVENT_TYPES = %w[
      found
      applied
      status_changed
      followed_up
      interview_scheduled
      interview_completed
      test_received
      test_completed
      rejected
      offer_received
      withdrawn
      ghosted
      note
    ].freeze

    belongs_to :account
    belongs_to :job_application,
      class_name: "Career::JobApplication",
      foreign_key: :career_job_application_id,
      inverse_of: :events

    validates :event_type, presence: true
    validates :event_type, inclusion: { in: EVENT_TYPES }
    validates :occurred_at, presence: true

    scope :for_account, ->(account) { where(account_id: account.id) }
    scope :recent_first, -> { order(occurred_at: :desc, created_at: :desc) }
  end
end
