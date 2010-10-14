module PurchaseRequestSuppliesHelper
  
  def display_associated_purchase_order(purchase_request_supply)
    return "Aucun" unless associated_purchase_order_supply = purchase_request_supply.confirmed_purchase_order_supply
    link_to(associated_purchase_order_supply.purchase_order.reference, purchase_order_path(associated_purchase_order_supply.purchase_order))
  end
  
  def check_request_supply_status(purchase_request_supply)
    return "non traité" if purchase_request_supply.untreated?  
    return "en cours de traitement" if purchase_request_supply.during_treatment? 
    return "traité" if purchase_request_supply.treated? 
  end
  
  def display_type_for(supply)
    return "Matière première" if supply.type == "Commodity"
    return "Consomable" if supply.type == "Consumable" 
  end
  
  def display_purchase_request_supply_expected_date(purchase_request_supply)
    return purchase_request_supply.expected_delivery_date.humanize
  end
  
  def display_add_unreferenced_supply_for(purchase_request)
    button_to_function "Ajouter un article non referenc&eacute;" do |page|
      page.insert_html :bottom, :purchase_request_supply_form, :partial => 'purchase_request_supplies/purchase_request_supply_in_one_line',
                                                   :object  => purchase_request.purchase_request_supplies.build, :locals => { :purchase_request => purchase_request }
                                                   
      last_item = page[:purchase_request_supply_form].select('.unreferenced_supply').last.show.visual_effect :highlight
      page << "initialize_autoresize_text_areas()"
    end
  end
  
  def display_action_button_for(purchase_request_supply)
   return "" unless purchase_request_supply.can_be_cancelled?
    link_to( image_tag( "cancel_16x16.png",
                        :alt => text = "Annuler cette fourniture",
                        :title => text ),
                        purchase_request_cancel_supply_path(purchase_request_supply.purchase_request_id, purchase_request_supply.id),
                      :confirm => "Êtes-vous sûr ?" ) 
  end
end
