module CommoditiesQuery
  def query_td_for_reference_in_commodity(content)
    content_tag(:td, link_to(content, @query_object), :class => :reference)
  end
  
  def query_td_for_designation_in_commodity(content)
    content_tag(:td, link_to(content, @query_object), :class => "designation text")
  end
  
  def query_td_for_measure_in_commodity(content)
    content_tag(:td, content, :class => :unit_measure)
  end
  
  def query_td_content_for_measure_in_commodity
    unit_measure_symbol = @query_object.unit_measure.symbol if @query_object.unit_measure
    @query_object.measure ? "#{@query_object.measure} #{unit_measure_symbol}" : "-"
  end
  
  def query_td_for_unit_mass_price_in_commodity(content)
    content_tag(:td, content, :class => :unit_mass)
  end
  
  def query_td_content_for_unit_mass_in_commodity
    @query_object.unit_mass ? "#{@query_object.unit_mass} kg" : "-"
  end
  
  def query_td_for_average_unit_price_in_commodity(content)
    content_tag(:td, content, :class => "average_unit_price amount")
  end
  
  def query_td_content_for_average_unit_price_in_commodity
    @query_object.average_unit_price ? "#{number_with_precision(@query_object.average_unit_price, :precision => 2)} &euro;" : "-"
  end
  
  def query_td_for_average_measure_price_in_commodity(content)
    content_tag(:td, content, :class => "average_measure_price amount")
  end
  
  def query_td_content_for_average_measure_price_in_commodity
    @query_object.average_measure_price ? "#{number_with_precision(@query_object.average_measure_price, :precision => 2)} &euro;/#{display_supply_unit_measure(@query_object)}" : "-"
  end
end
