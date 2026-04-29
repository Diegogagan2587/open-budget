class AddInterestRateEstimatedToIncomeEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :income_events, :interest_rate_estimated, :boolean, null: false, default: false
  end
end
