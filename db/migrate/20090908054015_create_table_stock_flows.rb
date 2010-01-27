class CreateTableStockFlows < ActiveRecord::Migration
  def self.up
    create_table :stock_flows do |t|
      t.string :type, :purchase_number, :file_number
      t.integer :supply_id, :supplier_id
      t.decimal :fob_unit_price, :tax_coefficient, :quantity, :previous_stock_quantity, :previous_stock_value, :precision => 65 ,:scale => 18
      t.boolean :adjustment
      t.timestamps
    end
  end

  def self.down
    drop_table :stock_flows
  end
end
