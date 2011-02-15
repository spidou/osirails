class CommodityTypesController < SupplyTypesController
  private
    def define_supply_type_class_and_supply_sub_category_class
      @supply_type_class = CommodityType
      @supply_sub_category_class = CommoditySubCategory
    end
end
