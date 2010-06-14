class CreatePurchaseRequestSupplies < ActiveRecord::Migration
  def self.up
    create_table  :purchase_request_supplies do |t|
      t.integer   :purchase_request_id
      t.integer   :supply_id
      t.integer   :purchase_order_supply_id
      t.integer   :cancelled_by
      
      t.integer   :expected_quantity
      t.string    :cancelled_comment

      t.datetime  :expected_delivery_date
      t.datetime  :cancelled_at
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_request_supplies
  end
end
