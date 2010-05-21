class StockInput < StockFlow
  has_permissions :as_business_object
  
  # Relationships  
  named_scope :commodities_stock_inputs, :conditions => ["supply_id IN (?) AND adjustment IS NULL",Commodity.find(:all)]
  named_scope :consumables_stock_inputs, :conditions => ["supply_id IN (?) AND adjustment IS NULL",Consumable.find(:all)]
  
  # Validates
  validates_numericality_of :fob_unit_price, :tax_coefficient
  validates_presence_of :purchase_number, :unless => :adjustment 
end

