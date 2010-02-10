module PressProofsHelper
  
  def display_actions_press_proof_button(press_proof)
    order = press_proof.order
    html = []
    html << display_confirm_button(order, press_proof, '')
    html << display_send_button(order, press_proof, '')
    html << display_dunning_add_button(order, press_proof, '')
    html << display_sign_button(order, press_proof, '')
    html << display_cancel_button(order, press_proof, '')
    html << display_revoke_button(order, press_proof, '')
    html << display_signed_press_proof_button(order, press_proof, '')
    html << display_show_button(order, press_proof, '')
    html << display_edit_button(order, press_proof, '')
    html << display_destroy_button(order, press_proof, '')
    html.compact.join("&nbsp;")
  end
  
  def display_list_button(step, message=nil)
    return unless PressProof.can_add?(current_user)
    text = "Voir les BAT"
    message ||= " #{text}"
    link_to( image_tag( "list_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             send(step.original_step.path))
  end
  
  def display_add_button(order, message=nil)
    return unless PressProof.can_add?(current_user)
    text = "Nouveau BAT"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_order_commercial_step_press_proof_step_press_proof_path(order))
  end
  
  def display_confirm_button(order, press_proof, message=nil)
    return unless PressProof.can_confirm?(current_user) and press_proof.can_be_confirmed?
    text = "Valider ce BAT"
    message ||= " #{text}"
    link_to( image_tag( "confirm_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_confirm_path(order, press_proof),
             :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le BAT et vous ne pourrez plus le modifier." )
  end
  
  def display_cancel_button(order, press_proof, message=nil)
    return unless PressProof.can_cancel?(current_user) and press_proof.can_be_cancelled?
    text = "Annuler ce BAT"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_cancel_path(order, press_proof),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_send_button(order, press_proof, message=nil)
    return unless PressProof.can_send_to_customer?(current_user) and press_proof.can_be_sended?     
    text = "Signaler que le BAT a été envoyé au client"
    message ||= " #{text}"
    link_to( image_tag( "send_to_customer_16x16.png",
                        :alt => text = "Signaler que le BAT a été envoyé au client",
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_send_form_path(order, press_proof) )
  end
  
  def display_sign_button(order, press_proof, message=nil)
    return unless PressProof.can_sign?(current_user) and press_proof.can_be_signed?     
    text = "Signaler que le client a signé ce BAT"
    message ||= " #{text}"
    link_to( image_tag( "sign_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_sign_form_path(order, press_proof) )
  end
  
  def display_revoke_button(order, press_proof, message=nil)
    return unless PressProof.can_revoke?(current_user) and press_proof.can_be_revoked?  
    text = "Annuler ce BAT"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_revoke_form_path(order, press_proof) )
  end
  
  def display_edit_button(order, press_proof, message=nil)
    return unless PressProof.can_edit?(current_user) and press_proof.can_be_edited?
    text = "Modifier ce BAT"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_order_commercial_step_press_proof_step_press_proof_path(order, press_proof) )
  end
  
  def display_show_button(order, press_proof, message=nil)
    return unless PressProof.can_view?(current_user)
    text = "Voir ce BAT"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_path(order, press_proof) )
  end
  
  def display_destroy_button(order, press_proof, message=nil)
    return unless PressProof.can_delete?(current_user) and press_proof.can_be_destroyed?
    text = "Supprimer ce BAT"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_path(order, press_proof), :method => :delete, :confirm => "Êtes vous sûr?") 
  end
  
  def display_signed_press_proof_button(order, press_proof, message=nil)
    return unless PressProof.can_view?(current_user) and press_proof.signed? and press_proof.signed_press_proof
    text = "Télécharger le BAT signé"
    message ||= " #{text}"
    link_to( image_tag( "mime_type_extensions/pdf_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_signed_press_proof_path(order, press_proof))
  end
  
  def status_text(press_proof)
    case press_proof.status
      when nil
        'Brouillon'
      when PressProof::STATUS_CANCELLED
        'Annulé'
      when PressProof::STATUS_CONFIRMED
        'Validé'
      when PressProof::STATUS_SENDED
        'Envoyé'
      when PressProof::STATUS_SIGNED
        'Signé'
      when PressProof::STATUS_REVOKED
        'Annulé (après signature)'
    end
  end
  
end
