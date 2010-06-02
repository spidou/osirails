class PurchaseRequest < ActiveRecord::Base
  
  #relationships
  has_many :purchase_supplies
  
end
