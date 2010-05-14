class ConsumableSubCategoriesController < SupplySubCategoriesController
  private
    def define_supply_type_and_supply_category_type
      @supply_type = Consumable
      @supply_category_type = ConsumableSubCategory
      @supply_parent_category_type = ConsumableCategory
    end
end
