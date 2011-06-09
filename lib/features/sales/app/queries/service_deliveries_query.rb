module ServiceDeliveriesQuery
    
  def query_td_for_reference_in_service_delivery(content)
    content_tag(:td, link_to(content, @query_object), :class => 'reference text')
  end
  
  def query_td_for_designation_in_service_delivery(content)
    content_tag(:td, link_to(content, @query_object), :class => 'designation text')
  end
  
  def query_td_for_description_in_service_delivery(content)
    content_tag(:td, content, :class => 'description text')
  end
  
  def query_td_content_for_time_scale_in_service_delivery
    ts = @query_object.time_scale || 'fixed'
    t("view.service_delivery.time_scales.#{ts}", :default => ts)
  end
  
  def query_td_content_for_cost_in_service_delivery
    content_tag(:span, @query_object.cost.to_f.round_to(2).to_s(2), :title => @query_object.cost)
  end
  
  def query_td_content_for_margin_in_service_delivery
    content_tag(:span, @query_object.margin.to_f.round_to(2).to_s(2), :title => @query_object.margin)
  end
  
  def query_td_content_for_unit_price_in_service_delivery
    content_tag(:span, @query_object.unit_price.to_f.round_to(2).to_s(2), :title => @query_object.unit_price)
  end
  
  def query_td_content_for_unit_price_with_taxes_in_service_delivery
    content_tag(:span, @query_object.unit_price_with_taxes.to_f.round_to(2).to_s(2), :title => @query_object.unit_price_with_taxes)
  end
  
  def query_group_td_content_in_service_delivery(group_by)
    content_tag(:span, :class => 'not-collapsed', :onclick => "toggleGroup(this);") do
      group_by.map do |g|
        case g[:attribute]
        when 'time_scale'
          ts = g[:value] || 'fixed'
          t("view.service_delivery.time_scales.#{ts}", :default => ts)
        end
      end.to_sentence
    end
  end
  
end
