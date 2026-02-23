class Meeting < ApplicationRecord
  belongs_to :account
  has_many :project_meetings, dependent: :destroy
  has_many :projects, through: :project_meetings

  validates :title, presence: true
  validates :start_time, presence: true

  scope :for_account, ->(account) { where(account_id: account.id) }
  scope :upcoming, -> { where("start_time > ?", Time.current).order(start_time: :asc) }

  before_create :set_account

  private

  def set_account
    self.account = Current.account if account.nil?
  end
end
