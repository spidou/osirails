module SuppliesHelper
  
  def display_supply_unit_measure(supply)
    "<span class=\"supply_unit_measure_symbol\">#{supply.unit_measure.symbol if supply.unit_measure}</span>"
  end
end
