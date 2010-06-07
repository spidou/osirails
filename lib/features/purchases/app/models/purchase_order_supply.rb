class PurchaseOrderSupply < ActiveRecord::Base
  
  #relationships
  belongs_to :purchase_order
  has_one :purchase_request_supply
  
end
