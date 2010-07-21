class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    create_table :purchase_orders do |t|
      t.references  :user, :supplier, :invoice_document
      t.references  :quotation_document, :payment_document
      t.integer     :cancelled_by, :status
      t.string      :reference, :cancelled_comment
      t.datetime    :cancelled_at
      t.date        :confirmed_on, :processing_by_supplier_since, :completed_on
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_orders
  end
end
