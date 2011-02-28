class ConsumablesController < SuppliesController
  private
    def define_classes
      @supply_class = Consumable
      @supply_category_class = ConsumableCategory
      @supply_sub_category_class = ConsumableSubCategory
      @supply_type_class = ConsumableType
    end
end
