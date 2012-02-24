class UpdateQuotesRemoveDefaultValueForDeposit < ActiveRecord::Migration
  def self.up
    change_column_default(:quotes, :deposit, nil)
  end

  def self.down
    change_column_default(:quotes, :deposit, 0.0)
  end
end
