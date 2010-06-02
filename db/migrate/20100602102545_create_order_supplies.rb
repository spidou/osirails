class CreateOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table :order_supplies do |t|
      t.integer :purchase_order_id
      t.integer :supply_id
      t.integer :quantity
      t.datetime :previsional_delivery_date
      t.string :status
      t.integer :parcel_id

      t.timestamps
    end
  end

  def self.down
    drop_table :order_supplies
  end
end
