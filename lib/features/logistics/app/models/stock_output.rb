class StockOutput < StockFlow
  has_permissions :as_business_object
  
  validate :validates_stock_availability
  
  @@form_labels[:identifier] = "Numéro de dossier :"
  
  def validates_stock_availability
    return unless supply and quantity
    supply = Supply.find(supply_id)
    errors.add(:quantity, "La quantité choisie est supérieure au stock disponible pour cette fourniture (#{quantity} > #{supply.stock_quantity})") if quantity > supply.stock_quantity
  end
  
  def set_up_default_unit_price
    return unless supply
    self.unit_price = supply.average_unit_stock_value
  end
  
  def calculation_method; :- end
end
