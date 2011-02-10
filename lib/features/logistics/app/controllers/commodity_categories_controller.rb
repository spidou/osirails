class CommodityCategoriesController < SupplyCategoriesController
  private
    def define_supply_class_and_supply_category_class
      @supply_class = Commodity
      @supply_category_class = CommodityCategory
    end
end
