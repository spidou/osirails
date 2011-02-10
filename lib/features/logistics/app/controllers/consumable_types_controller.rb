class ConsumableTypesController < SupplyTypesController
  private
    def define_supply_type_class_and_supply_sub_category_class
      @supply_type_class = ConsumableType
      @supply_sub_category_class = ConsumableSubCategory
    end
end
