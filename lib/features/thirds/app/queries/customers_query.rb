require_dependency "thirds_query"

module CustomersQuery
  include ThirdsQuery  
  
  alias_method :query_td_for_name_in_customer, :query_td_for_name_in_third
  alias_method :query_td_for_legal_form_name_in_customer, :query_td_for_legal_form_name_in_third
  
  def query_td_for_brand_names_in_customer(content)
    content_tag(:td, content, :class => :text)
  end
  
  def query_td_content_for_brand_names_in_customer
    @query_object.brand_names.join(', ')
  end
  
  def query_td_for_head_office_activity_sector_reference_get_activity_sector_name_in_customer(content)
    content_tag(:td, content, :class => :text)
  end

end
