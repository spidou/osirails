class Parcel < ActiveRecord::Base
  
  #relationships
  belongs_to :purchase_order_supply
end
