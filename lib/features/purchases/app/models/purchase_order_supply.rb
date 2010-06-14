class PurchaseOrderSupply < ActiveRecord::Base
  
  #relationships
  belongs_to :purchase_order
  
  has_many  :request_order_supplies
  has_many  :purchase_request_supplies, :through => :request_order_supplies
 
  
end
