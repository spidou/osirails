module LeaveRequestsHelper
  
  def view_status(leave_request)
    case leave_request.status_was
      when 1
        "En attente de la réponse du responsable"
      when 2
        "En attente de notification par les ressources humaines"
      when -2
        "Refusée par le responsable"
      when 3
        "En attente de la réponse de la direction"
      when 4 
        "Acceptée"
      when -4 
        "Refusée par la direction"
      when 0 
        "Annulée par #{cancelled_by(leave_request)}"  
     end
  end
  
  def cancelled_by(leave_request)
    case leave_request.cancelled_by
      when leave_request.employee_id
        "le demandeur"
      when leave_request.responsible_id
        "le responsable"
      when leave_request.observer_id
        "les ressources humaines"
      when leave_request.director_id
        "la direction"
    end
  end
  
  def view_start_half(leave_request)
    if leave_request.start_half
      "après-midi" 
    else
      "matin"
    end 
  end
  
  def view_end_half(leave_request)
    if leave_request.end_half
      "matin" 
    else
      "après-midi"
    end 
  end
  
  def view_dates(leave_request)
    "Du #{leave_request.start_date.strftime("%A %d %B %Y")} (#{view_start_half(leave_request)}) au #{leave_request.end_date.strftime("%A %d %B %Y")} (#{view_end_half(leave_request)})"
  end
  
  def view_responsible_agreement(leave_request)
    if leave_request.responsible_agreement
      "ACCORDÉ"
    else
      "REFUSÉ"
    end
  end
  
  def view_director_agreement(leave_request)
    if leave_request.director_agreement
      "ACCORDÉ"
    else
      "REFUSÉ"
    end
  end
  
  def accepted_leave_requests_link
    link_to(image_tag("view_16x16.png") + " Voir toutes mes demandes acceptées", accepted_leave_requests_path)
  end
  
  def refused_leave_requests_link
    link_to(image_tag("view_16x16.png") + " Voir toutes mes demandes refusées", refused_leave_requests_path)
  end
  
  def cancelled_leave_requests_link
    link_to(image_tag("view_16x16.png") + " Voir toutes mes demandes annulées", cancelled_leave_requests_path)
  end
  
end
