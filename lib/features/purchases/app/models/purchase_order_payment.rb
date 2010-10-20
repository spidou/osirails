class PurchaseOrderPayment < ActiveRecord::Base
  
  belongs_to  :purchase_order
  belongs_to  :deposit_payment_method, :class_name => "PaymentMethod", :foreign_key => "deposit_payment_method_id"
  belongs_to  :balance_payment_method, :class_name => "PaymentMethod", :foreign_key => "balance_payment_method_id"
  
  validates_presence_of :purchase_order_id
  validates_presence_of :purchase_order, :if => :purchase_order_id
  validates_presence_of :comment
  validates_presence_of :deposit_payment_method_id, :if => :deposit_amount
  validates_presence_of :deposit_payment_method, :if => :deposit_payment_method_id
  validates_presence_of :payment_before_shipment, :unless => :payment_on_delivery
  validates_presence_of :payment_on_delivery, :unless => :payment_before_shipment
  
  validates_numericality_of :deposit_amount, :greater_than_or_equal_to => 0
  
  validate :validates_context_of_payment
  
  def validates_context_of_payment
    if (payment_before_shipment && payment_on_delivery)
      errors.add(self, "veuillez choisir 'paiement avant exp&eacute;dition' OU 'paiment &agrave; la livraison'")
    end
  end
  
end
