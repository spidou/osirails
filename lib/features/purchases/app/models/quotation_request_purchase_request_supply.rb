class QuotationRequestPurchaseRequestSupply < ActiveRecord::Base
  belongs_to :quotation_request_supply
  belongs_to :purchase_request_supply
  
  validates_presence_of :purchase_request_supply_id
  validates_presence_of :purchase_request_supply, :if => :purchase_request_supply
end
