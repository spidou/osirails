module ThirdsHelper
  def contextual_search_for_customer
    contextual_search("Customer", [ "*",
                                    "activity_sector.name",
                                    "legal_form.name",
                                    "establishments.name",
                                    "establishments.contacts.*"] )
  end
  
  def contextual_search_for_supplier
    contextual_search("Supplier", [ "*",
                                    "activity_sector.name",
                                    "legal_form.name",
                                    "contacts.first_name", 
                                    "contacts.last_name",
                                    "iban.*"] )
  end
end
