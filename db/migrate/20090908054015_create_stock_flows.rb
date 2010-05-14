class CreateStockFlows < ActiveRecord::Migration
  def self.up
    create_table :stock_flows do |t|
      t.references :supply, :inventory
      t.string  :type, :identifier
      t.decimal :unit_price, :previous_stock_value, :precision => 65 ,:scale => 18
      t.integer :quantity, :previous_stock_quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :stock_flows
  end
end
