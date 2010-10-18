module QuotationRequestSuppliesHelper

  def display_add_free_quotation_request_supply_for(quotation_request)
    button_to_function "Ajouter une fourniture qui n'existe pas dans la base"  do |page|
      page.insert_html :bottom, :quotation_request_supplies_body, :partial => 'quotation_request_supplies/quotation_request_supply', :object  => quotation_request.quotation_request_supplies.build
      last_item = page["quotation_request_supplies_body"].select('.free_quotation_request_supply').last.show.visual_effect "highlight" # :quotation_request_supplies_body  symbol replaced by "quotation_request_supplies_body" string and :highlight symbol replaced by "highlight" string to relieve to the "undefined method `ascii_only?' for {}:Hash" error
      
      page << "update_up_down_links_for_quotation_request($('quotation_request_supplies_body'))"
    end
  end
  
  def display_add_comment_line_for(quotation_request)
    button_to_function "Ajouter ligne de commentaire"  do |page|
      page.insert_html :bottom, :quotation_request_supplies_body, :partial => 'quotation_request_supplies/quotation_request_supply', :object  => quotation_request.quotation_request_supplies.build(:comment_line => true)
      last_item = page["quotation_request_supplies_body"].select('.comment_line').last.show.visual_effect "highlight" # :quotation_request_supplies_body  symbol replaced by "quotation_request_supplies_body" string and :highlight symbol replaced by "highlight" string to relieve to the "undefined method `ascii_only?' for {}:Hash" error, in views
      
      page << "update_up_down_links_for_quotation_request($('quotation_request_supplies_body'))"
      page << "initialize_autoresize_text_areas()"
    end
  end
end
