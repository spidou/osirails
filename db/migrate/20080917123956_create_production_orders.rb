class CreateProductionOrders < ActiveRecord::Migration
  def self.up
    create_table :production_orders do |t|
      
      t.timestamps
    end
  end

  def self.down
    drop_table :production_orders
  end
end
