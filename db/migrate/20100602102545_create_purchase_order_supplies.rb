class CreatePurchaseOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table  :purchase_order_supplies do |t|
      t.integer   :purchase_order_id
      t.integer   :supply_id
      t.integer   :cancelled_by
      t.integer   :parcel_id

      t.integer   :quantity
      t.string    :status
      t.string    :cancelled_comment

      t.datetime  :previsional_delivery_date
      t.datetime  :returned_at
      t.datetime  :forwarded_at
      t.datetime  :reimboursed_at
      t.datetime  :cancelled_at
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_supplies
  end
end
