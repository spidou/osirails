module SuppliesHelper
  
  # This method permit to show unit_measure for commodity
  def show_parent_measure(supply_category_id,supply_category)
    supply_category = supply_category.class.find(supply_category_id)
    unit_measure = UnitMeasure.find(supply_category.unit_measure_id)
    unit_measure.symbol+"/U :"
  end

end
