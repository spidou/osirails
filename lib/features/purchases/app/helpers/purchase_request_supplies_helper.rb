module PurchaseRequestSuppliesHelper
  
  def verify_validity_of_purchase_request_supply(purchase_request_supply)
    return image_tag('warning_14x14.png', :alt => "warning", :title => "Cette demande d'achat est associ&eacute;e &agrave; un ordre d'achat qui est d&eacute;j&agrave; confirm&eacute; vous devez le d&eacute;s&eacute;lectionn&eacute; ou supprim&eacute; la fourniture pour pouvoir confimer votre demande de devis.") if purchase_request_supply.confirmed_purchase_order_supply
    "" 
  end
  
  def display_unconfirmed_purchase_request_supplies_references(owner)
    html = []
    owner.unconfirmed_purchase_request_supplies.each do |purchase_request_supply|
      html << (link_to purchase_request_supply.purchase_request.reference + verify_validity_of_purchase_request_supply(purchase_request_supply), purchase_request_path(purchase_request_supply.purchase_request), :popup => true)
    end
    html.join("<br />")
  end
  
  def display_unconfirmed_purchase_request_supplies_expected_quantities(owner)
    html = []
    owner.unconfirmed_purchase_request_supplies.each do |purchase_request_supply|
      html << purchase_request_supply.expected_quantity.to_s
    end
    html.join("<br />")
  end
  
  def display_unconfirmed_purchase_request_supplies_check_boxes(owner, disabled = false)
    html = []
    owner.unconfirmed_purchase_request_supplies.each do |purchase_request_supply|
      html << ( check_box_tag purchase_request_supply.id, 
                purchase_request_supply.id, 
                owner.already_associated_with_purchase_request_supply?(purchase_request_supply), 
                :data_quantity => purchase_request_supply.expected_quantity.to_s, 
                :idx => (owner.already_associated_with_purchase_request_supply?(purchase_request_supply) ? 1 : 0), 
                :onchange => "update_purchase_request_supplies_ids(this, this.up('.resource'))",
                :disabled => disabled)
    end
    html.join("<br />")
  end
  
  def display_associated_purchase_request_supplies_references(owner)
    html = []
    html << owner.purchase_request_supplies.collect{ |prs| link_to(prs.purchase_request.reference, purchase_request_path(prs.purchase_request)) }
    html.join("<br />")
  end
  
  def display_associated_purchase_order(purchase_request_supply)
    return "Aucun" unless associated_purchase_order_supply = purchase_request_supply.confirmed_purchase_order_supply
    link_to(associated_purchase_order_supply.purchase_order.reference, purchase_order_path(associated_purchase_order_supply.purchase_order))
  end
  
  def check_request_supply_status(purchase_request_supply)
    return "non traité" if purchase_request_supply.untreated?  
    return "en cours de traitement" if purchase_request_supply.during_treatment? 
    "traité" if purchase_request_supply.treated? 
  end
  
  def display_type_for(supply)
    return "Matière première" if supply.type == "Commodity"
    "Consomable" if supply.type == "Consumable" 
  end
  
  def display_purchase_request_supply_expected_date(purchase_request_supply)
    purchase_request_supply.expected_delivery_date.humanize
  end
  
  def display_associated_purchase_request(purchase_request_supply)
    link_to(purchase_request_supply.purchase_request.reference, purchase_request_path(purchase_request_supply.purchase_request))
  end
  
  def display_supply_stock_and_supply_threshold(purchase_request_supply)
    supply = purchase_request_supply.supply if purchase_request_supply.supply_id
    (supply.stock_quantity.to_s + "/" + supply.threshold.to_i.to_s)
  end
  
  def display_add_unreferenced_supply_for(purchase_request)
    button_to_function "Ajouter un article non referenc&eacute;" do |page|
      page.insert_html :bottom, :purchase_request_supply_form, :partial => 'purchase_request_supplies/purchase_request_supply_in_one_line',
                                                   :object  => purchase_request.purchase_request_supplies.build, :locals => { :purchase_request => purchase_request }
                                                   
      last_item = page["purchase_request_supply_form"].select('.unreferenced_supply').last.show.visual_effect "highlight" # :highlight symbol replaced by "highlight" string to relieve to the "undefined method `ascii_only?' for {}:Hash" error, in views
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
