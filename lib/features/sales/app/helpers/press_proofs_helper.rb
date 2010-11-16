module PressProofsHelper
  
  def display_press_proofs(order)
    press_proofs = order.press_proofs.reject(&:new_record?)
    if press_proofs.empty?
      content_tag(:p, "Aucun BAT n'a été trouvé")
    else
      render :partial => 'press_proofs/press_proofs_list', :object => press_proofs
    end
  end
  
  def press_proof_action_buttons(press_proof)
    order = press_proof.order
    html = []
    html << display_press_proof_show_button(order, press_proof)
    html << display_press_proof_edit_button(order, press_proof)
    html << display_press_proof_preview_button(order, press_proof)
    html << display_press_proof_show_pdf_button(order, press_proof)
    html << display_press_proof_signed_button(order, press_proof)
    
    html << display_press_proof_confirm_button(order, press_proof)
    html << display_press_proof_send_button(order, press_proof)
    html << display_dunning_add_button(order, press_proof)
    html << display_press_proof_sign_button(order, press_proof)
    html << display_press_proof_cancel_button(order, press_proof)
    html << display_press_proof_revoke_button(order, press_proof)
    html << display_press_proof_destroy_button(order, press_proof)
    html.compact
  end
  
  def display_press_proof_list_button(step, message = nil)
    return unless PressProof.can_add?(current_user)
    link_to(message || "Voir les BAT du dossier",
            send(step.original_step.path),
            'data-icon' => :index)
  end
  
  def display_press_proof_add_button(order, message = nil)
    return unless PressProof.can_add?(current_user)
    link_to_unless_current(message || "Nouveau BAT",
                           new_order_commercial_step_press_proof_step_press_proof_path(order),
                           'data-icon' => :new) {nil}
  end
  
  def display_press_proof_confirm_button(order, press_proof, message = nil)
    return unless PressProof.can_confirm?(current_user) and press_proof.can_be_confirmed?
    link_to(message || "Valider",
            order_commercial_step_press_proof_step_press_proof_confirm_path(order, press_proof),
            :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le BAT et vous ne pourrez plus le modifier.",
            'data-icon' => :confirm)
  end
  
  def display_press_proof_cancel_button(order, press_proof, message = nil)
    return unless PressProof.can_cancel?(current_user) and press_proof.can_be_cancelled?
    link_to(message || "Annuler",
            order_commercial_step_press_proof_step_press_proof_cancel_path(order, press_proof),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :cancel)
  end
  
  def display_press_proof_send_button(order, press_proof, message = nil)
    return unless PressProof.can_send_to_customer?(current_user) and press_proof.can_be_sended?     
    link_to_unless_current(message || "Signaler l'envoi au client",
                           order_commercial_step_press_proof_step_press_proof_send_form_path(order, press_proof),
                           'data-icon' => :send) {nil}
  end
  
  def display_press_proof_sign_button(order, press_proof, message = nil)
    return unless PressProof.can_sign?(current_user) and press_proof.can_be_signed?     
    link_to(message || "Signaler la signature par le client",
            order_commercial_step_press_proof_step_press_proof_sign_form_path(order, press_proof),
            'data-icon' => :sign)
  end
  
  def display_press_proof_revoke_button(order, press_proof, message = nil)
    return unless PressProof.can_revoke?(current_user) and press_proof.can_be_revoked?  
    link_to_unless_current(message || "Annuler",
                           order_commercial_step_press_proof_step_press_proof_revoke_form_path(order, press_proof),
                           'data-icon' => :cancel) {nil}
  end
  
  def display_press_proof_edit_button(order, press_proof, message = nil)
    return unless PressProof.can_edit?(current_user) and !press_proof.new_record? and press_proof.can_be_edited?
    link_to_unless_current(message || "Modifier",
                           edit_order_commercial_step_press_proof_step_press_proof_path(order, press_proof),
                           'data-icon' => :edit) {nil}
  end
  
  def display_press_proof_show_button(order, press_proof, message = nil)
    return unless PressProof.can_view?(current_user) and !press_proof.new_record?
    link_to_unless_current(message || "Voir",
                           order_commercial_step_press_proof_step_press_proof_path(order, press_proof),
                           'data-icon' => :show) {nil}
  end
  
  def display_press_proof_preview_button(order, press_proof, message = nil)
    return unless PressProof.can_view?(current_user) and !press_proof.new_record? and !press_proof.can_be_downloaded?
    link_to(message || "Aperçu (PDF)",
            order_commercial_step_press_proof_step_press_proof_path(order, press_proof, :format => :pdf),
            'data-icon' => :preview)
  end
  
  def display_press_proof_show_pdf_button(order, press_proof, message = nil)
    return unless PressProof.can_view?(current_user) and press_proof.can_be_downloaded?
    link_to(message || "Télécharger (PDF)",
            order_commercial_step_press_proof_step_press_proof_path(order, press_proof, :format => :pdf),
            'data-icon' => :download)
  end
  
  def display_press_proof_destroy_button(order, press_proof, message = nil)
    return unless PressProof.can_delete?(current_user) and !press_proof.new_record? and press_proof.can_be_destroyed?
    link_to(message || "Supprimer",
            order_commercial_step_press_proof_step_press_proof_path(order, press_proof),
            :method => :delete,
            :confirm => "Êtes vous sûr?",
            'data-icon' => :delete) 
  end
  
  def display_press_proof_signed_button(order, press_proof, message = nil) # renommer en #display_signed_press_proof_button
    return unless PressProof.can_view?(current_user) and press_proof.signed? and press_proof.signed_press_proof
    link_to(message || "Télécharger le BAT signé",
            order_commercial_step_press_proof_step_press_proof_signed_press_proof_path(order, press_proof),
            'data-icon' => :download)
  end
  
  def press_proof_status_text(press_proof)
    case press_proof.status
      when nil                          then 'Brouillon'
      when PressProof::STATUS_CANCELLED then 'Annulé'
      when PressProof::STATUS_CONFIRMED then 'Validé'
      when PressProof::STATUS_SENDED    then 'Envoyé'
      when PressProof::STATUS_SIGNED    then 'Signé'
      when PressProof::STATUS_REVOKED   then 'Annulé (après signature)'
    end
  end
  
end
