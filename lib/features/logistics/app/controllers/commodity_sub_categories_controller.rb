class CommoditySubCategoriesController < SupplySubCategoriesController
  private
    def define_supply_class_and_supply_category_class
      @supply_class = Commodity
      @supply_category_class = CommoditySubCategory
      @supply_parent_category_class = CommodityCategory
    end
end
