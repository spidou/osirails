class CommoditiesManagerController < SuppliesManagerController
  
  def define_supply_class_and_supply_category_class
    @supply_class = Commodity
    @supply_category_class = CommodityCategory
    @supply_sub_category_class = CommoditySubCategory
  end
  
end
