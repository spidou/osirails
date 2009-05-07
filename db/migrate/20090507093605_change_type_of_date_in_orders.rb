class ChangeTypeOfDateInOrders < ActiveRecord::Migration
  def self.up
    change_column :orders, :previsional_start, :date
    change_column :orders, :previsional_delivery, :date
  end

  def self.down
    change_column :orders, :previsional_start, :datetime
    change_column :orders, :previsional_delivery, :datetime
  end
end
