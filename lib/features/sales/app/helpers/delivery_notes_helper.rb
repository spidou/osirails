module DeliveryNotesHelper
  
  def display_delivery_notes(order)
    delivery_notes = order.delivery_notes.reject(&:new_record?)
    if delivery_notes.empty?
      content_tag(:p, "Aucun bon de livraison n'a été trouvé")
    else
      render :partial => 'delivery_notes/delivery_notes', :object => delivery_notes
    end
  end
  
  def display_delivery_note_action_buttons(order, delivery_note)
    html = []
    html << display_delivery_note_confirm_button(order, delivery_note, '')
    html << display_delivery_note_realize_button(order, delivery_note, '')
    html << display_delivery_note_schedule_button(order, delivery_note, '')
    html << display_delivery_note_download_attachment_button(order, delivery_note, '')
    html << display_delivery_note_sign_button(order, delivery_note, '')
    html << display_delivery_note_cancel_button(order, delivery_note, '')
    
    html << display_delivery_note_preview_button(order, delivery_note, '')
    html << display_delivery_note_show_pdf_button(order, delivery_note, '')
    html << display_delivery_note_show_button(order, delivery_note, '')
    html << display_delivery_note_edit_button(order, delivery_note, '')
    html << display_delivery_note_delete_button(order, delivery_note, '')
    
    html.compact.join("&nbsp;")
  end
  
  def display_delivery_note_list_button(step, message = nil)
    return unless DeliveryNote.can_add?(current_user)
    text = "Voir les bons de livraison"
    message ||= " #{text}"
    link_to( image_tag( "list_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             send(step.original_step.path))
  end
  
  def display_delivery_note_add_button(order, message = nil)
    return unless DeliveryNote.can_add?(current_user) and order.delivery_notes.build.can_be_added?
    text = "Nouveau bon de livraison"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_order_production_step_delivery_step_delivery_note_path(order))
  end
  
  def display_delivery_note_show_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_view?(current_user) and !delivery_note.new_record?
    text = "Voir ce bon de livraison"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_path(order, delivery_note) )
  end
  
  def display_delivery_note_preview_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_view?(current_user) and !delivery_note.new_record? and !delivery_note.can_be_downloaded?
    text = "Télécharger un aperçu de ce BL (PDF)"
    message ||= " #{text}"
    link_to( image_tag( "preview_16x16.gif",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_path(order, delivery_note, :format => :pdf) )
  end
  
  def display_delivery_note_show_pdf_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_view?(current_user) and delivery_note.can_be_downloaded?
    text = "Télécharger ce BL (PDF)"
    message ||= " #{text}"
    link_to( image_tag( "mime_type_extensions/pdf_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_path(order, delivery_note, :format => :pdf) )
  end
  
  def display_delivery_note_edit_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_edit?(current_user) and delivery_note.can_be_edited?
    text = "Modifier ce bon de livraison"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_order_production_step_delivery_step_delivery_note_path(order, delivery_note) )
  end
  
  def display_delivery_note_delete_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_delete?(current_user) and delivery_note.can_be_destroyed?
    text = "Supprimer ce bon de livraison"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_path(order, delivery_note), :method => :delete, :confirm => "Êtes vous sûr?") 
  end
  
  def display_delivery_note_confirm_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_confirm?(current_user) and delivery_note.can_be_confirmed?
    text = "Valider ce bon de livraison"
    message ||= " #{text}"
    link_to( image_tag( "confirm_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_confirm_path(order, delivery_note),
             :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le bon de livraison et vous ne pourrez plus le modifier." )
  end
  
  def display_delivery_note_schedule_button(order, delivery_note, message = nil)
    return unless DeliveryIntervention.can_add?(current_user) and DeliveryIntervention.can_edit?(current_user) and delivery_note.can_be_scheduled?
    text = "Planifier une intervention pour ce BL"
    message ||= " #{text}"
    link_to( image_tag( "schedule_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_schedule_form_path(order, delivery_note) )
  end
  
  def display_delivery_note_realize_button(order, delivery_note, message = nil)
    return unless DeliveryIntervention.can_edit?(current_user) and delivery_note.can_be_realized?
    text = "Signaler la réalisation de l'intervention pour ce BL"
    message ||= " #{text}"
    link_to( image_tag( "realize_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_realize_form_path(order, delivery_note) )
  end
  
  def display_delivery_note_cancel_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_cancel?(current_user) and delivery_note.can_be_cancelled?
    text = "Annuler ce bon de livraison"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_cancel_path(order, delivery_note),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_delivery_note_sign_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_sign?(current_user) and delivery_note.can_be_signed?
    text = "Signaler la signature du BL par le client"
    message ||= " #{text}"
    link_to( image_tag( "sign_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_sign_form_path(order, delivery_note) )
  end
  
  def display_delivery_note_download_attachment_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_view?(current_user) and delivery_note.was_signed?
    text = "Télécharger le BL signé (PDF)"
    message ||= " #{text}"
    link_to( image_tag( "mime_type_extensions/pdf_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_production_step_delivery_step_delivery_note_attachment_path(order, delivery_note) )
  end
  
  def status_text(delivery_note)
    case delivery_note.status
      when nil
        'Brouillon'
      when DeliveryNote::STATUS_CANCELLED
        'Annulé'
      when PressProof::STATUS_CONFIRMED
        'Validé'
      when PressProof::STATUS_SIGNED
        'Signé'
    end
  end
  
end
