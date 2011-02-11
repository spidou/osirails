class CommoditiesController < SuppliesController
  private
    def define_supply_type_and_supply_category_type
      @supply_class = Commodity
      @supply_category_class = CommodityCategory
      @supply_sub_category_class = CommoditySubCategory
      @supply_type_class = CommodityType
    end
end
