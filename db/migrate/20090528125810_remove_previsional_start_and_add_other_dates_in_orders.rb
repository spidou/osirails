class RemovePrevisionalStartAndAddOtherDatesInOrders < ActiveRecord::Migration
  def self.up
    remove_column :orders, :previsional_start
    add_column :orders, :quotation_deadline, :date
    add_column :orders, :delivery_time, :integer
  end

  def self.down
    add_column :orders, :previsional_start, :date
    remove_column :orders, :quotation_deadline
    remove_column :orders, :delivery_time
  end
end
