class CreatePurchaseOrderPayments < ActiveRecord::Migration
  def self.up
    create_table    :purchase_order_payments do |t|
      t.references  :purchase_order, :deposit_payment_method, :balance_payment_method
      t.integer     :number_of_due_dates
      t.float       :deposit_amount
      t.text        :comment
      t.boolean     :payed, :payment_before_shipment, :payment_on_delivery
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_payments
  end
end
