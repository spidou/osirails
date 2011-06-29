require_dependency "thirds_query"

module SuppliersQuery
  include ThirdsQuery

  alias_method :query_td_for_name_in_supplier, :query_td_for_name_in_third
  alias_method :query_td_for_legal_form_name_in_supplier, :query_td_for_legal_form_name_in_third
  
  alias_method :query_td_for_activity_sector_reference_get_activity_sector_name_in_supplier, :query_td_for_activity_sector_reference_get_activity_sector_name_in_third
  
  def query_td_for_address_zip_code_and_city_name_in_supplier(content)
    content_tag(:td, content, :class => :text)
  end
end
