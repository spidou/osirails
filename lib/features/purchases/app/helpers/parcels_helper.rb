module ParcelsHelper
  def display_parcel_recovered(parcel)
    return image_tag( "cross_16x16.png", :alt => "Non récupéré", :title => "Non récupéré" ) unless parcel.status == Parcel::STATUS_RECOVERED
    image_tag( "tick_16x16.png", :alt => "Récupéré", :title => "Récupéré" )
  end
  
  def display_parcel_current_status(parcel)
    case parcel.status
      when Parcel::STATUS_PROCESSING
        'En traitement'
      when Parcel::STATUS_SHIPPED
        'Envoyé'
      when Parcel::STATUS_RECEIVED
        'Reçu'
      when Parcel::STATUS_RECOVERED
        'Récupéré'
      else
        "Impossible d'afficher le statut correspondant pour le colis"
    end
  end
  
  def display_parcel_current_status_date(parcel)
    case parcel.status 
      when Parcel::STATUS_PROCESSING
        parcel.created_at ? parcel.created_at.humanize : "Aucune date de début de traitement"
      when Parcel::STATUS_SHIPPED
        parcel.shipped_at ? parcel.shipped_at.humanize : "Aucune date de postage"
      when Parcel::STATUS_RECEIVED
        parcel.received_at ? parcel.received_at.humanize : "Aucune date de réception"
      when Parcel::STATUS_RECOVERED
        parcel.recovered_at ? parcel.recovered_at.humanize : "Aucune date de récupération"
      else
        "Impossible de trouver le statut correspondant pour le colis"
    end
  end
  
  def display_parcel_previsional_deliveray_date(parcel)
    return parcel.previsional_delivery_date.humanize unless parcel.previsional_delivery_date == nil
    "Non définie"
  end
end
