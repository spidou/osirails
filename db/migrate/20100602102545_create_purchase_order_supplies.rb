class CreatePurchaseOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table  :purchase_order_supplies do |t|
      t.integer   :purchase_order_id
      t.integer   :supply_id
      t.integer   :quantity
      t.datetime  :previsional_delivery_date
      t.integer   :parcel_id
      t.datetime  :returned_at
      t.datetime  :redirected_at
      t.datetime  :cancelled_at
      t.string    :cancelled_comment
      t.integer   :cancelled_by
      t.string    :status
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_supplies
  end
end
