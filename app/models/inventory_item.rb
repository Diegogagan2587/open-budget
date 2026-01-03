class InventoryItem < ApplicationRecord
  belongs_to :account
  belongs_to :category, optional: true

  before_validation :set_account, on: :create

  scope :for_account, ->(account) { where(account: account) }
  scope :in_stock, -> { where(stock_state: "in_stock") }
  scope :low, -> { where(stock_state: "low") }
  scope :empty, -> { where(stock_state: "empty") }
  scope :consumable, -> { where(consumable: true) }

  validates :name, presence: true
  validates :stock_state, presence: true, inclusion: { in: %w[in_stock low empty] }

  def add_to_shopping_list!
    shopping_item = ShoppingItem.create!(
      account: account,
      category: category,
      name: name,
      status: "pending",
      item_type: "one_time",
      notes: "Added from inventory"
    )
    shopping_item
  end

  private

  def set_account
    self.account ||= Current.account if Current.account
  end
end
