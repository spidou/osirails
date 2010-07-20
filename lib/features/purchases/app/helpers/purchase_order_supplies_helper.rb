module PurchaseOrderSuppliesHelper
  
  def display_purchase_order_supply_buttons(purchase_order_supply)
    html = []
    html << display_supply_show_button(purchase_order_supply.supply, '')
    html << display_purchase_order_supply_cancel_button(purchase_order_supply, '')
    html.compact.join("&nbsp;")
  end
  
  def display_supply_show_button(supply, message = nil)
    text = "Voir les détails de cette fourniture"
    message ||= " #{text}"
    supply.type == "Consumable" ? url = consumable_path(supply) : url = commodity_path(supply)
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             url, :popup => true )
  end
  
  def display_purchase_order_supply_cancel_button(purchase_order_supply, message = nil)
    return unless PurchaseOrderSupply.can_cancel?(current_user) and purchase_order_supply.can_be_cancelled?
    text = "Annuler cette fourniture"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             purchase_order_purchase_order_supply_cancel_form_path(purchase_order_supply.purchase_order_id, purchase_order_supply.id),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_purchase_order_supply_reference(purchase_order_supply)
    return "" unless purchase_order_supply.supply.reference
    purchase_order_supply.supply.reference
  end
  
  def display_purchase_order_supply_unit_price_including_tax(purchase_order_supply)
    unit_price = purchase_order_supply.get_unit_price_including_tax
    unit_price.to_f.to_s(2) + "&nbsp;&euro;"
  end
  
  def display_purchase_order_supply_total(purchase_order_supply, supplier_id = 0, supply_id = 0)
    if purchase_order_supply.new_record?
      if purchase_order_supply.get_supplier_supply(supplier_id, supply_id)
        supplier_supply = purchase_order_supply.get_supplier_supply(supplier_id, supply_id)
        purchase_order_supply.quantity.to_f * (supplier_supply.fob_unit_price.to_f * ((100 + supplier_supply.taxes.to_f)/100))
      else
        return 0
      end
    else
      return 0 unless purchase_order_supply
      purchase_order_supply.get_purchase_order_supply_total.to_s(2) +"&nbsp;&euro;"
    end
  end
  
  def display_purchase_order_supply_status(purchase_order_supply)
    if purchase_order_supply.untreated?
      "Non traité"
    elsif purchase_order_supply.processing_by_supplier?
      "En traitement"
    elsif purchase_order_supply.treated?
      "Traité"
    elsif purchase_order_supply.cancelled?
      "Annulé"
    end
  end
  
  def display_purchase_order_supply_current_status_date(purchase_order_supply)
    if purchase_order_supply.untreated?
      purchase_order_supply.created_at ? purchase_order_supply.created_at.humanize : "Aucune date de création"
    elsif purchase_order_supply.processing_by_supplier?
      purchase_order_supply.parcel_items.first.created_at ? purchase_order_supply.parcel_items.first.created_at.humanize : "Aucune date de début de traitement"
    elsif purchase_order_supply.treated?
      purchase_order_supply.parcel_items.last.created_at ? purchase_order_supply.parcel_items.last.created_at.humanize : ""
    elsif purchase_order_supply.was_cancelled?
      purchase_order_supply.cancelled_at ? purchase_order_supply.cancelled_at.humanize : "Aucune date d'annulation"
    end
  end
  
  def display_purchase_order_supply_associated_purchase_requests(purchase_order_supply)
    html = []
    associated_purchase_requests_supplies = purchase_order_supply.purchase_request_supplies
    return if associated_purchase_requests_supplies.empty?
    for purchase_request_supply in associated_purchase_requests_supplies
      html << link_to(purchase_request_supply.purchase_request.reference, purchase_request_path(purchase_request_supply.purchase_request))
    end
    html.compact.join("<br />")
  end
  
    
  def display_purchase_order_supply_associated_parcels(purchase_order_supply)
    return unless purchase_order_supply.parcels.any?
    html = []
    for parcel in purchase_order_supply.parcels
      html << "<tr><td>" + link_to( parcel.reference, purchase_order_parcel_path(purchase_order_supply.purchase_order, parcel)) + "</td></tr>"
    end
    html << "<tr><td></td></tr>" if html.empty?
    html.compact.join()
  end
  
  def display_purchase_order_supply_supplier_designation(purchase_order_supply)
    return purchase_order_supply.supplier_designation if purchase_order_supply.supplier_designation
    purchase_order_supply.get_supplier_supply.supplier_designation
  end
  
  def display_purchase_order_supply_supplier_reference(purchase_order_supply)
    return unless purchase_order_supply.supplier_reference or purchase_order_supply.get_supplier_supply.supplier_reference
    purchase_order_supply.supplier_reference or purchase_order_supply.get_supplier_supply.supplier_reference
  end
  
  def display_purchase_order_lead_time(purchase_order_supply)
    lead_time = purchase_order_supply.get_supplier_supply.lead_time
    if !lead_time
      "Non renseigné"
    elsif lead_time == 0
      "Immédiat"
    else
      lead_time.to_s + "&nbsp;jour(s)"
    end
  end
  
  def verify_validity_of_purchase_request_supply(purchase_request_supply)
    return image_tag('warning_14x14.png', :alt => "warning", :title => "cette demande d'achat est associ&eacute;e a un ordre d'achat qui est d&eacute;j&agrave; confirm&eacute; vous devez le d&eacute;s&eacute;lectionn&eacute; ou supprim&eacute; la fourniture pour pouvoir confimer votre ordre.") if purchase_request_supply.confirmed_purchase_order_supply
    return "" 
  end
  
end
