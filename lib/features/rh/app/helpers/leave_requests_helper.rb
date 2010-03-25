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
    text = "Voir toutes mes demandes acceptées"
    link_to(image_tag("view_16x16.png", :alt => text, :title => text) + " " + text, accepted_leave_requests_path)
  end
  
  def refused_leave_requests_link
    text = "Voir toutes mes demandes refusées"
    link_to(image_tag("view_16x16.png", :alt => text, :title => text) + " " + text, refused_leave_requests_path)
  end
  
  def cancelled_leave_requests_link
    text = "Voir toutes mes demandes annulées"
    link_to(image_tag("view_16x16.png", :alt => text, :title => text) + " " + text, cancelled_leave_requests_path)
  end
  
  def leave_request_check_form_link(leave_request)
    text = "Traiter la demande de congés"
    link_to(image_tag("edit_16x16.png", :alt => text, :title => text), leave_request_check_form_path(leave_request))
  end
  
  def leave_request_notice_form_link(leave_request)
    text = "Traiter la demande de congés"
    link_to(image_tag("edit_16x16.png", :alt => text, :title => text), leave_request_notice_form_path(leave_request))
  end
  
  def leave_request_close_form_link(leave_request)
    text = "Traiter la demande de congés"
    link_to(image_tag("edit_16x16.png", :alt => text, :title => text), leave_request_close_form_path(leave_request))
  end  
  
  def cancel_leave_request_link(leave_request, button) 
    text = "Annuler la demande de congés"
    link_text = button ? "" : " #{text}"
    link_to(image_tag("delete_16x16.png", :alt => text, :title => text) + link_text, cancel_leave_request_path(leave_request), :confirm => "Êtes-vous sûr ?")
  end
  
  def determine_action_for_pending_leave_request(leave_request)
    if leave_request.submitted_or_refused_by_responsible?
      leave_request_check_form_link(leave_request)
    elsif leave_request.checked?
      leave_request_notice_form_link(leave_request)
    elsif leave_request.noticed_or_refused_by_director?
      leave_request_close_form_link(leave_request)
    end
  end
  
end
