class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    create_table :purchase_orders do |t|
      t.references  :user, :supplier, :invoice_document
      t.references  :quotation_document, :payment_document
      t.integer     :cancelled_by
      t.string      :reference,:status, :cancelled_comment
      t.datetime    :confirmed_at, :processing_since, :completed_at, :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_orders
  end
end
