class CreatePurchaseDeliveryItems < ActiveRecord::Migration
  def self.up
    create_table :purchase_delivery_items do |t|
      t.references  :purchase_delivery, :purchase_order_supply, :issue_purchase_order_supply, :cancelled_by
      t.integer   :quantity, :issues_quantity
      t.boolean   :must_be_reshipped, :send_back_to_supplier
      t.text      :issues_comment, :cancelled_comment
      t.datetime  :cancelled_at, :issued_at

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_delivery_items
  end
end
