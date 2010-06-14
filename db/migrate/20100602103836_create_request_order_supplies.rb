class CreateRequestOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table  :request_order_supplies do |t|
      t.integer   :purchase_request_supply_id
      t.integer   :purchase_order_supply_id

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_request_supplies
  end
end
