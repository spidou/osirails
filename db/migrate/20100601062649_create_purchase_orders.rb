class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    create_table :purchase_orders do |t|
      t.references  :user, :supplier, :invoice_document, :delivery_document
      t.references  :payment_document, :payment_method, :quotation_document
      t.integer     :cancelled_by
      t.string      :reference,:status, :cancelled_comment
      t.boolean     :paid, :direct
      t.datetime    :confirmed_at, :processing_since, :completed_at, :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_orders
  end
end
