class PremiaColumnNamePremium < ActiveRecord::Migration
  def self.up
    rename_column :premia, :premium, :amount
  end

  def self.down
    rename_column :premia, :amount, :premium
  end
end
