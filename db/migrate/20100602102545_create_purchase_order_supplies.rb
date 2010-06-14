class CreatePurchaseOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table :purchase_order_supplies do |t|
      t.references  :purchase_order, :supply, :parcel
      t.integer     :cancelled_by, :quantity
      t.string      :status, :cancelled_comment
      t.datetime    :previsional_delivery_date, :returned_at, :forwarded_at
      t.datetime    :reimboursed_at, :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_supplies
  end
end
