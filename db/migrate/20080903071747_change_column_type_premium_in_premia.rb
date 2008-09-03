class ChangeColumnTypePremiumInPremia < ActiveRecord::Migration
  def self.up
    remove_column :premia ,:premium
    add_column :premia, :premium, :decimal ,:precision => 65 ,:scale => 30
  end

  def self.down
    remove_column :premia ,:premium
    add_column :premia, :premium , :float
  end
end
