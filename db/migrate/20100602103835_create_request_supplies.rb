class CreateRequestSupplies < ActiveRecord::Migration
  def self.up
    create_table :request_supplies do |t|
      t.integer :purchase_request_id
      t.integer :supply_id
      t.integer :expected_quantity
      t.datetime :ecpected_delivery_date
      t.integer :order_supply_id
      t.datetime :cancelled_at
      t.string :cancelled_comment
      t.integer :cancelled_by

      t.timestamps
    end
  end

  def self.down
  end
end
