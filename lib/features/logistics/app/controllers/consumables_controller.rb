class ConsumablesController < SuppliesController
  private
    def define_supply_type_and_supply_category_type
      @supply_class = Consumable
      @supply_category_class = ConsumableCategory
      @supply_sub_category_class = ConsumableSubCategory
      @supply_type_class = ConsumableType
    end
end
