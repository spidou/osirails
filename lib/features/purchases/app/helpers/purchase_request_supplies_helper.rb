module PurchaseRequestSuppliesHelper
  
  def verify_validity_of_purchase_request_supply(purchase_request_supply)
    return image_tag('warning_14x14.png', :alt => "warning", :title => "Cette demande d'achat est associ&eacute;e &agrave; un ordre d'achats qui est d&eacute;j&agrave; confirm&eacute; vous devez le d&eacute;s&eacute;lectionn&eacute; ou supprim&eacute; la fourniture pour pouvoir confimer votre demande de devis.") if purchase_request_supply.confirmed_purchase_order_supply
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
end
