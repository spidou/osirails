class PurchaseSupply < ActiveRecord::Base
  
  #relationships
  belongs_to :purchase_request
end
