class CreatePurchaseSupplies < ActiveRecord::Migration
  def self.up
    create_table :purchase_supplies do |t|
      t.integer :purchase_request_id
      t.integer :purchase_order_id
      t.integer :supply_id
      t.integer :expected_quantity
      t.integer :quantity
      t.datetime :expected_delivery_date
      t.datetime :previsional_delivery_date
      t.datetime :delivery_date
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_supplies
  end
end
