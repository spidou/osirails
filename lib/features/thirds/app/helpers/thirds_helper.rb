module ThirdsHelper
#  def contextual_search_for_customer
#    contextual_search("Customer", [ "*",
#                                    "legal_form.name",
#                                    "establishments.name",
#                                    "establishments.contacts.*"] )
#  end
#  
#  def contextual_search_for_supplier
#    contextual_search("Supplier", [ "*",
#                                    "activity_sector_reference.code",
#                                    "activity_sector_reference.activity_sector.name",
#                                    "activity_sector_reference.custom_activity_sector.name",
#                                    "legal_form.name",
#                                    "contacts.first_name", 
#                                    "contacts.last_name",
#                                    "iban.*"] )
#  end
  
  def query_td_for_name_in_customer(content)
    content_tag(:td, link_to(content, @query_object))
  end
  
  def query_td_content_for_brand_names_in_customer
    @query_object.brand_names.join(', ')
  end
end
