class CreatePurchaseOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table :purchase_order_supplies do |t|
      t.references  :purchase_order, :supply, :parcel, :reshipped_purchase_order_supply
      t.integer     :cancelled_by, :quantity
      t.float       :taxes, :fob_unit_price
      t.string      :status, :supplier_reference, :supplier_designation
      t.text        :cancelled_comment
      t.datetime    :processing_since, :sent_back_at, :reshipped_at, :reimbursed_at, :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_supplies
  end
end
