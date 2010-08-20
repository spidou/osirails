class StockInput < StockFlow
  has_permissions :as_business_object
  
  def set_up_default_unit_price
    return unless supply and from_inventory?
    self.unit_price = supply.average_unit_stock_value
  end
  
  def calculation_method; :+ end
end
