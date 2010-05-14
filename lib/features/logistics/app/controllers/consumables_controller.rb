class ConsumablesController < SuppliesController
  private
    def define_supply_type_and_supply_category_type
      @supply_type = Consumable
      @supply_category_type = ConsumableCategory
      @supply_sub_category_type = ConsumableSubCategory
    end
end
