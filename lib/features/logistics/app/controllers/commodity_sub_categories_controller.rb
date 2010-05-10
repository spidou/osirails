class CommoditySubCategoriesController < SupplySubCategoriesController
  private
    def define_supply_type_and_supply_category_type
      @supply_type = Commodity
      @supply_category_type = CommoditySubCategory
      @supply_parent_category_type = CommodityCategory
    end
end
