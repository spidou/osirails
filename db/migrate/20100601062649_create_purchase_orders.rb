class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    create_table :purchase_orders do |t|
      t.integer :user_id
      t.integer :supplier_id
      t.string :reference
      t.string :status
      t.datetime :cancelled_at
      t.string :cancelled_comment
      t.integer :order_document_id
      t.integer :invoice_document_id
      t.integer :delivery_document_id

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_orders
  end
end
