class CreatePurchaseOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table :purchase_order_supplies do |t|
      t.references  :purchase_order, :supply, :cancelled_by
      t.integer   :quantity
      t.float     :taxes, :fob_unit_price
      t.string    :supplier_reference, :supplier_designation
      t.text      :cancelled_comment
      t.datetime  :cancelled_at

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_supplies
  end
end

