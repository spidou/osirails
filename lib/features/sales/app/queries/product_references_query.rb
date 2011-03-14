module ProductReferencesQuery
    
  def query_td_for_reference_in_product_reference(content)
    content_tag(:td, link_to(content, @query_object), :class => 'reference text')
  end
  
  def query_td_for_designation_in_product_reference(content)
    content_tag(:td, link_to(content, @query_object), :class => 'designation text')
  end
  
  def query_td_for_description_in_product_reference(content)
    content_tag(:td, content, :class => 'description text')
  end
  
  #TODO this method would have permitted to display count of product_references for categories,
  #     but it's impossible to recover the object of the group right now
  #def query_group_td_content_in_product_reference(group_by)
  #  content_tag(:span, :class => 'not-collapsed', :onclick => "toggleGroup(this);") do
  #    group_by.map{ |n| "#{n[:value]} (??)" }.join(" -> ")
  #  end
  #end
end
