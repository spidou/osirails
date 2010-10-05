module QuotationRequestSuppliesHelper

  def verify_validity_of_purchase_request_supply(purchase_request_supply)
    return image_tag('warning_14x14.png', :alt => "warning", :title => "Cette demande d'achat est associ&eacute;e &agrave; un ordre d'achats qui est d&eacute;j&agrave; confirm&eacute; vous devez le d&eacute;s&eacute;lectionn&eacute; ou supprim&eacute; la fourniture pour pouvoir confimer votre demande de devis.") if purchase_request_supply.confirmed_purchase_order_supply
    "" 
  end
  
  def display_add_free_quotation_request_supply_for(quotation_request)
    button_to_function "Ajouter une fourniture qui n'existe pas dans la base"  do |page|
      page.insert_html :bottom, :quotation_request_supplies_body, :partial => 'quotation_request_supplies/quotation_request_supply', :object  => quotation_request.quotation_request_supplies.build
      last_item = page[:quotation_request_supplies_body].select('.free_quotation_request_supply').last.show.visual_effect :highlight
      
      page << "update_up_down_links_for_quotation_request($('quotation_request_supplies_body'))"
    end
  end
  
  def display_add_comment_line_for(quotation_request)
    button_to_function "Ajouter ligne de commentaire"  do |page|
      page.insert_html :bottom, :quotation_request_supplies_body, :partial => 'quotation_request_supplies/quotation_request_supply', :object  => quotation_request.quotation_request_supplies.build(:comment_line => true)
      last_item = page[:quotation_request_supplies_body].select('.comment_line').last.show.visual_effect :highlight
      
      page << "update_up_down_links_for_quotation_request($('quotation_request_supplies_body'))"
    end
  end
  
end
