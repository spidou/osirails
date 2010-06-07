class CreatePurchaseRequestSupplies < ActiveRecord::Migration
  def self.up
    create_table  :purchase_request_supplies do |t|
      t.integer   :purchase_request_id
      t.integer   :supply_id
      t.integer   :expected_quantity
      t.datetime  :expected_delivery_date
      t.integer   :purchase_order_supply_id
      t.datetime  :cancelled_at
      t.string    :cancelled_comment
      t.integer   :cancelled_by

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_request_supplies
  end
end
