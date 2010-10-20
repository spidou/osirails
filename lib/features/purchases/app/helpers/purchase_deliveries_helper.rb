module PurchaseDeliveriesHelper
  def generate_purchase_delivery_contextual_menu_partial(purchase_order = nil, purchase_delivery = nil)
    render :partial => 'purchase_deliveries/contextual_menu', :object => purchase_delivery, :locals => {:purchase_order => purchase_order}
  end
  
  def display_purchase_delivery_reference(purchase_delivery)
    link_to(purchase_delivery.reference, purchase_order_purchase_delivery_path(purchase_delivery.purchase_delivery_items.first.purchase_order_supply.purchase_order, purchase_delivery))
  end
 
  def display_purchase_delivery_current_status(purchase_delivery)
    if purchase_delivery.was_cancelled?
      "Annulé"
    elsif purchase_delivery.was_received?
      "Reçu"
    elsif purchase_delivery.was_received_by_forwarder?
      "Reçu par le transitaire"
    elsif purchase_delivery.was_shipped?
      "Expédié"
    elsif purchase_delivery.was_processing_by_supplier?
      "En traitement"
    else
      ""
    end
  end
  
  def display_purchase_delivery_current_status_date(purchase_delivery)
    if purchase_delivery.was_cancelled?
      display_purchase_delivery_cancelled_at(purchase_delivery)
    elsif purchase_delivery.was_received?
      display_purchase_delivery_received_on(purchase_delivery)
    elsif purchase_delivery.was_received_by_forwarder?
      display_purchase_delivery_received_by_forwarder_on(purchase_delivery)
    elsif purchase_delivery.was_shipped?
      display_purchase_delivery_shipped_on(purchase_delivery)
    elsif purchase_delivery.was_processing_by_supplier?
      display_purchase_delivery_processing_by_supplier_since(purchase_delivery)
    else
      ""
    end
  end
  
  def display_purchase_delivery_created_at(purchase_delivery)
    return purchase_delivery.created_at.humanize
  end
  
  def display_purchase_delivery_previsional_deliveray_date(purchase_delivery)
    return purchase_delivery.previsional_delivery_date.humanize if purchase_delivery.previsional_delivery_date
    ""
  end
  
  def display_purchase_delivery_processing_by_supplier_since(purchase_delivery)
    return purchase_delivery.processing_by_supplier_since.humanize if purchase_delivery.processing_by_supplier_since
    ""
  end
  
  def display_purchase_delivery_shipped_on(purchase_delivery)
    return purchase_delivery.shipped_on.humanize if purchase_delivery.shipped_on
    ""
  end
  
  def display_purchase_delivery_received_by_forwarder_on(purchase_delivery)
    return purchase_delivery.received_by_forwarder_on.humanize if purchase_delivery.received_by_forwarder_on
    ""
  end
  
  def display_purchase_delivery_received_on(purchase_delivery)
    return purchase_delivery.received_on.humanize if purchase_delivery.received_on
    ""
  end
  
  def display_purchase_delivery_cancelled_at(purchase_delivery)
    return purchase_delivery.cancelled_at.humanize if purchase_delivery.cancelled_at
    return purchase_delivery.purchase_delivery_items.all(:order => "cancelled_at").last.cancelled_at.humanize if purchase_delivery.was_cancelled? 
    ""
  end
  
  def display_purchase_delivery_buttons(purchase_delivery)
    html = []
    html << display_purchase_delivery_show_button(purchase_delivery, '')
    html << display_purchase_delivery_cancel_button(purchase_order_supply, '')
    html.compact.join("&nbsp;")
  end
  
  def display_purchase_delivery_show_button(supply, message = nil)
    text = "Voir les détails de ce colis"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             purchase_order_purchase_delivery_path(purchase_delivery), :popup => true )
  end
  
  def purchase_delivery_possible_actions(purchase_delivery)
    options = []
    (options << ["En attente d'expédition", Parcel::STATUS_PROCESSING_BY_SUPPLIER ]) if purchase_delivery.can_be_processed_by_supplier?
    (options << ["Expédié", Parcel::STATUS_SHIPPED ]) if purchase_delivery.can_be_shipped?
    (options << ["Reçu par le transitaire", Parcel::STATUS_RECEIVED_BY_FORWARDER ]) if purchase_delivery.can_be_received_by_forwarder?
    (options << ["Reçu", Parcel::STATUS_RECEIVED ]) if purchase_delivery.can_be_received?
    (options << ["Annulé", Parcel::STATUS_CANCELLED ]) if purchase_delivery.can_be_cancelled?
    
    options
  end
  
  def purchase_delivery_all_actions_without_cancel(purchase_delivery)
    options = []
    options << ["En attente d'expédition", Parcel::STATUS_PROCESSING_BY_SUPPLIER ]
    options << ["Expédié", Parcel::STATUS_SHIPPED ]
    options << ["Reçu par le transitaire", Parcel::STATUS_RECEIVED_BY_FORWARDER ] 
    options << ["Reçu", Parcel::STATUS_RECEIVED ]
    options
  end
end
