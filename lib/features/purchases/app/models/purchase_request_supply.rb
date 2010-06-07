class PurchaseRequestSupply < ActiveRecord::Base
  
  #relationships
  belongs_to :purchase_request
  belongs_to :purchase_order_supply
  belongs_to :supply
  
  #validations
  validates_presence_of :supply_id, :expected_quantity, :expected_delivery_date
  validates_numericality_of :expected_quantity, :greater_than => 0
  
  
  #method
  def check_status
    status = ''   
    status = PurchaseRequest::STATUS_UNTRAITED unless self.purchase_order_supply_id
    status = PurchaseRequest::STATUS_DURING_TRAITMENT if self.purchase_order_supply_id and  self.purchase_order_supply.purchase_order.status == PurchaseOrder::STATUS_DRAFT and self.purchase_order_supply.purchase_order.cancelled_by == nil
    status = PurchaseRequest::STATUS_DURING_TRAITMENT if self.purchase_order_supply_id and  self.purchase_order_supply.purchase_order.status != PurchaseOrder::STATUS_DRAFT and self.purchase_order_supply.purchase_order.cancelled_by == nil   
    status
  end
end
