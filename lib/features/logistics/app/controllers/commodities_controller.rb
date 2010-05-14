class CommoditiesController < SuppliesController
  private
    def define_supply_type_and_supply_category_type
      @supply_type = Commodity
      @supply_category_type = CommodityCategory
      @supply_sub_category_type = CommoditySubCategory
    end
end
