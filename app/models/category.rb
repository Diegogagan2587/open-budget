class Category < ApplicationRecord
  has_many :expense_templates, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :budget_line_items, dependent: :destroy
  has_many :planned_expenses, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
