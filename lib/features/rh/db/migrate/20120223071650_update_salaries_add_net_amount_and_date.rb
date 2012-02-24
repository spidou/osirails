class UpdateSalariesAddNetAmountAndDate < ActiveRecord::Migration
  def self.up
    add_column :salaries, :net_amount, :decimal, :precision => 65, :scale => 20
    add_column :salaries, :date, :date
  end

  def self.down
    remove_column :salaries, :net_amount
    remove_column :salaries, :date
  end
end
