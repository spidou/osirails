class ConsumablesManagerController < SuppliesManagerController
  
  def define_supply_class_and_supply_category_class
    @supply_class = Consumable
    @supply_category_class = ConsumableCategory
  end
  
end
