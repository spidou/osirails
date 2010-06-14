class RequestOrderSupply < ActiveRecord::Base
  
  #relationships
  belongs_to :purchase_order_supply
  belongs_to :purchase_request_supply

end
