class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    create_table :purchase_orders do |t|
      t.references  :user, :supplier, :invoice_document, :quotation_document, :cancelled_by, :quotation, :supplier_contact
      t.integer     :status
      t.float       :prizegiving, :miscellaneous
      t.string      :reference
      t.text        :cancelled_comment
      t.boolean     :expected_delivery
      t.datetime    :cancelled_at, :purchased_on
      t.date        :confirmed_on, :processing_by_supplier_since, :completed_on

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_orders
  end
end
