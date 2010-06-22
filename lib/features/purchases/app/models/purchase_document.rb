class PurchaseDocument < ActiveRecord::Base
  belongs_to :purchase_order_supply
end
