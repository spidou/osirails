module ParcelsHelper
  def display_parcel_current_status(parcel)
    if parcel.was_cancelled?
      "Annulé"
    elsif parcel.was_received?
      "Reçu"
    elsif parcel.was_received_by_forwarder?
      "Reçu par le transitaire"
    elsif parcel.was_shipped?
      "Expédié"
    elsif parcel.was_processing_by_supplier?
      "En traitement"
    else
      ""
    end
  end
  
  def display_parcel_current_status_date(parcel)
    if parcel.was_cancelled?
      display_parcel_cancelled_at(parcel)
    elsif parcel.was_received?
      display_parcel_received_on(parcel)
    elsif parcel.was_received_by_forwarder?
      display_parcel_received_by_forwarder_on(parcel)
    elsif parcel.was_shipped?
      display_parcel_shipped_on(parcel)
    elsif parcel.was_processing_by_supplier?
      display_parcel_processing_by_supplier_since(parcel)
    else
      ""
    end
  end
  
  def display_parcel_created_at(parcel)
    return parcel.created_at.humanize
  end
  
  def display_parcel_previsional_deliveray_date(parcel)
    return parcel.previsional_delivery_date.humanize if parcel.previsional_delivery_date
    ""
  end
  
  def display_parcel_processing_by_supplier_since(parcel)
    return parcel.processing_by_supplier_since.humanize if parcel.processing_by_supplier_since
    ""
  end
  
  def display_parcel_shipped_on(parcel)
    return parcel.shipped_on.humanize if parcel.shipped_on
    ""
  end
  
  def display_parcel_received_by_forwarder_on(parcel)
    return parcel.received_by_forwarder_on.humanize if parcel.received_by_forwarder_on
    ""
  end
  
  def display_parcel_received_on(parcel)
    return parcel.received_on.humanize if parcel.received_on
    ""
  end
  
  def display_parcel_cancelled_at(parcel)
    return parcel.cancelled_at.humanize if parcel.cancelled_at
    return parcel.parcel_items.all(:order => "cancelled_at").last.cancelled_at.humanize if parcel.was_cancelled? 
    ""
  end
  
  def display_parcel_buttons(parcel)
    html = []
    html << display_parcel_show_button(parcel, '')
    html << display_parcel_cancel_button(purchase_order_supply, '')
    html.compact.join("&nbsp;")
  end
  
  def display_parcel_show_button(supply, message = nil)
    text = "Voir les détails de ce colis"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             purchase_order_parcel_path(parcel), :popup => true )
  end
  
  def parcel_possible_actions(parcel)
    options = []
    (options << ["En traitement", Parcel::STATUS_PROCESSING_BY_SUPPLIER ]) if parcel.can_be_processed_by_supplier?
    (options << ["Expédié", Parcel::STATUS_SHIPPED ]) if parcel.can_be_shipped?
    (options << ["Reçu par le transitaire", Parcel::STATUS_RECEIVED_BY_FORWARDER ]) if parcel.can_be_received_by_forwarder?
    (options << ["Reçu", Parcel::STATUS_RECEIVED ]) if parcel.can_be_received?
    (options << ["Annulé", Parcel::STATUS_CANCELLED ]) if parcel.can_be_cancelled?
    
    options
  end
  
  def parcel_all_actions_without_cancel(parcel)
    options = []
    options << ["En traitement", Parcel::STATUS_PROCESSING_BY_SUPPLIER ]
    options << ["Expédié", Parcel::STATUS_SHIPPED ]
    options << ["Reçu par le transitaire", Parcel::STATUS_RECEIVED_BY_FORWARDER ] 
    options << ["Reçu", Parcel::STATUS_RECEIVED ]
    options
  end
end
