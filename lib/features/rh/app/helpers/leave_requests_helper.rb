module LeaveRequestsHelper
  
  def view_status(leave_request)
    case leave_request.status
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
      "ACCORD"
    else
      "REFUS"
    end
  end
  
  def view_director_agreement(leave_request)
    if leave_request.director_agreement
      "ACCORD"
    else
      "REFUS"
    end
  end
  
  def accepted_leave_requests_link
    link_to "List all accepted leave requests", accepted_leave_requests_path
  end
  
  def refused_leave_requests_link
    link_to "List all refused leave requests", refused_leave_requests_path
  end

  
end
