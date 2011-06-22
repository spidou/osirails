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
    content = @query_object.average_unit_price ? "#{number_with_precision(@query_object.average_unit_price, :precision => 2)} &euro;" : "-"
    content_tag(:span, content, :class => (@query_object.average_unit_price && @query_object.average_unit_price.zero?) ? "zero" : nil)
  end
  
  def query_td_for_average_measure_price_in_commodity(content)
    content_tag(:td, content, :class => "average_measure_price amount")
  end
  
  def query_td_content_for_average_measure_price_in_commodity
    content = @query_object.average_measure_price ? "#{number_with_precision(@query_object.average_measure_price, :precision => 2)} &euro;/#{display_supply_unit_measure(@query_object)}" : "-"
    content_tag(:span, content, :class => (@query_object.average_measure_price && @query_object.average_measure_price.zero?) ? "zero" : nil)
  end
  
  def query_td_content_for_stock_quantity_in_commodity
    content_tag(:span, @query_object.stock_quantity, :class => @query_object.stock_quantity_smaller_than_threshold? ? "under_threshold" : nil)
  end
  
  def query_td_content_for_stock_quantity_at_last_inventory_in_commodity
    content_tag(:span, @query_object.stock_quantity_at_last_inventory, :class => @query_object.stock_quantity_at_last_inventory_smaller_than_threshold? ? "under_threshold" : nil)
  end
  
  def query_td_for_suppliers_in_commodity(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_suppliers_in_commodity
    html = ""
    if supplier = @query_object.suppliers.first
      html << supplier.name
      html << " (#{supplier.address.zip_code})" if supplier.address
    end
    if @query_object.suppliers.many?
      html << "&nbsp;"
      html << link_to("(#{@query_object.suppliers.count})", send("#{@query_object.class.name.underscore}_path", @query_object, :anchor => :suppliers))
    end
    
    html
  end
end
