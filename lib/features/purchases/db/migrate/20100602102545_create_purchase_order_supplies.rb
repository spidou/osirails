class CreatePurchaseOrderSupplies < ActiveRecord::Migration
  def self.up
    create_table :purchase_order_supplies do |t|
      t.references  :purchase_order, :supply, :cancelled_by
      t.integer     :quantity, :position
      t.float       :taxes, :fob_unit_price, :prizegiving
      t.string      :supplier_reference, :supplier_designation
      t.text        :cancelled_comment, :description
      t.datetime    :cancelled_at
      t.boolean     :comment_line
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_supplies
  end
end

