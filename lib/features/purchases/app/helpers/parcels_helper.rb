module ParcelsHelper
  def display_parcel_recovered(parcel)
    return image_tag( "cross_16x16.png", :alt => "Non récupéré", :title => "Non récupéré" ) unless parcel.status == Parcel::STATUS_RECEIVED_BY_FORWARDER
    image_tag( "tick_16x16.png", :alt => "Récupéré", :title => "Récupéré" )
  end
  
  def display_parcel_current_status(parcel)
    case parcel.status
      when Parcel::STATUS_PROCESSING_BY_SUPPLIER
        'En traitement'
      when Parcel::STATUS_SHIPPED
        'Envoyé'
      when Parcel::STATUS_RECEIVED_BY_FORWARDER
        'Reçu par le transitaire'
      when Parcel::STATUS_RECEIVED
        'Reçu'
      when Parcel::STATUS_CANCELLED
        'Annulé'
      else
        "Impossible d'afficher le statut correspondant pour le colis"
    end
  end
  
  def display_parcel_current_status_date(parcel)
    case parcel.status 
      when Parcel::STATUS_PROCESSING_BY_SUPPLIER
        parcel.created_at ? parcel.created_at.humanize : "Aucune date de début de traitement"
      when Parcel::STATUS_SHIPPED
        parcel.shipped_at ? parcel.shipped_at.humanize : "Aucune date de postage"
      when Parcel::STATUS_RECEIVED_BY_FORWARDER
        parcel.received_by_forwarder_at ? parcel.received_by_forwarder_at.humanize : "Aucune date de réception par le transitaire"
      when Parcel::STATUS_RECEIVED
        parcel.received_at ? parcel.received_at.humanize : "Aucune date de réception"
      when Parcel::STATUS_CANCELLED
        parcel.cancelled_at ? parcel.canncelled_at.humanize : "Aucune date d'annulation"
    end
  end
  
  def display_parcel_previsional_deliveray_date(parcel)
    return parcel.previsional_delivery_date.humanize unless parcel.previsional_delivery_date == nil
    "Non définie"
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
    (options << ["En traitement", Parcel::STATUS_PROCESSING_BY_SUPPLIER ]) if parcel.can_be_processing_by_supplier?
    (options << ["Expédié", Parcel::STATUS_SHIPPED ]) if parcel.can_be_shipped?
    (options << ["Reçu par le transitaire", Parcel::STATUS_RECEIVED_BY_FORWARDER ]) if parcel.can_be_received_by_forwarder?
    (options << ["Reçu", Parcel::STATUS_RECEIVED ]) if parcel.can_be_received?
    (options << ["Annulé", Parcel::STATUS_CANCELLED ]) if parcel.can_be_cancelled?
    
    options
  end
  
  def display_parcel_process_by_supplier(parcel, message = nil)
    #TODO
  end
  
  def display_parcel_ship(parcel, message = nil)
    #TODO
  end
  
  def display_parcel_receive_by_forwarder(parcel, message = nil)
    #TODO
  end
  
  def display_parcel_receive(parcel, message = nil)
    #TODO
  end
end
