class CreateRequestOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table :request_order_supplies do |t|
      t.references  :purchase_request_supply, :purchase_order_supply

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_request_supplies
  end
end
