module SupplyCategoriesHelper
  
  # This method permit to concat unit_measure name and symbol
  def format_unit_measure
    unit_measures = UnitMeasure.find(:all)
    unit_measures.each do |unit_measure|
      unit_measure.name += " (#{unit_measure.symbol})"
    end
    unit_measures
  end
end
