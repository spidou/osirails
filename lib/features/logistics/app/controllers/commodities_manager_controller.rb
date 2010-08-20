class CommoditiesManagerController < SuppliesManagerController
  
  def define_supply_type_and_supply_category_type
    @supply_type = Commodity
    @supply_category_type = CommodityCategory
  end
  
end
