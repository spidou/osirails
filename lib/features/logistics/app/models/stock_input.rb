class StockInput < StockFlow
  has_permissions :as_business_object
  
  named_scope :commodities_stock_inputs, :conditions => ["supply_id IN (?) AND adjustment IS NULL",Commodity.find(:all)]
  named_scope :consumables_stock_inputs, :conditions => ["supply_id IN (?) AND adjustment IS NULL",Consumable.find(:all)]
  
  with_options :unless => :adjustment do |t|
    t.validates_numericality_of :fob_unit_price, :tax_coefficient
    t.validates_presence_of :purchase_number
  end
  
  @@form_labels[:purchase_number] = "Numéro d'achat :"
  @@form_labels[:fob_unit_price] = "FOB unitaire :"
  @@form_labels[:tax_coefficient] = "Coefficient de taxe :"

  
end

