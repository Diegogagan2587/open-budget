class Expense < ApplicationRecord
  belongs_to :category
  belongs_to :budget_period
  belongs_to :income_event, optional: true
end
