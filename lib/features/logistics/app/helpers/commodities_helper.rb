module CommoditiesHelper
  
  # This method permit to show unit_measure for commodity
  def show_parent_measure(commodity_category_id)
    commodity_category = CommodityCategory.find(commodity_category_id)
    unit_measure = UnitMeasure.find(commodity_category.unit_measure_id)
    unit_measure.symbol+"/U :"
  end

end
