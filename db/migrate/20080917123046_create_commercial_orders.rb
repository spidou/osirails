class CreateCommercialOrders < ActiveRecord::Migration
  def self.up
    create_table :commercial_orders do |t|
      
      t.timestamps
    end
  end

  def self.down
    drop_table :commercial_orders
  end
end
