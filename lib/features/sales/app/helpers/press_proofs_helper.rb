module PressProofsHelper
  
  def display_actions_press_proof_button(order, press_proof)
    html = []
    html << display_confirm_button(order, press_proof, '')
    html << display_cancel_button(order, press_proof, '')
    html << display_send_button(order, press_proof, '')
    html << display_sign_button(order, press_proof, '')
    html << display_revoke_button(order, press_proof, '')
#    html << display_signed_press_proof_button(order, press_proof, '')
    html << display_show_button(order, press_proof, '')
    html << display_edit_button(order, press_proof, '')
    html << display_destroy_button(order, press_proof, '')
    html << display_dunning_add_button(order, press_proof, '')
    html.compact.join("&nbsp;")
  end
  
  def display_list_button(step, message=nil)
    return unless PressProof.can_add?(current_user)
    message ||= ' Lister les BATs'
    link_to( image_tag( "/images/list_16x16.png",
                        :alt => text = "Voir les BATs",
                        :title => text ) + message,
             send(step.original_step.path))
  end
  
  def display_add_button(order, message=nil)
    return unless PressProof.can_add?(current_user)
    message ||= ' Ajouter un BAT'
    link_to( image_tag( "/images/add_16x16.png",
                        :alt => text = "Ajouter un BAT",
                        :title => text ) + message,
             new_order_commercial_step_press_proof_step_press_proof_path(order))
  end
  
  def display_confirm_button(order, press_proof, message=nil)
    return unless PressProof.can_confirm?(current_user) and press_proof.can_be_confirmed?
    message ||= " Valider ce BAT"
    link_to( image_tag( "/images/confirm_16x16.png",
                        :alt => text = "Valider ce BAT",
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_confirm_path(order, press_proof),
             :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le BAT et vous ne pourrez plus le modifier." )
  end
  
  def display_cancel_button(order, press_proof, message=nil)
    return unless PressProof.can_cancel?(current_user) and press_proof.can_be_cancelled?
    message ||= ' Annuler ce BAT'
    link_to( image_tag( "/images/cancel_16x16.png",
                        :alt => text = "Invalider ce BAT",
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_cancel_path(order, press_proof),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_send_button(order, press_proof, message=nil)
    return unless PressProof.can_send_to_customer?(current_user) and press_proof.can_be_sended?     
    message ||= ' Envoyer ce BAT'
    link_to( image_tag( "/images/send_to_customer_16x16.png",
                        :alt => text = "Signaler que le BAT a été envoyé au client",
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_send_form_path(order, press_proof) )
  end
  
  def display_sign_button(order, press_proof, message=nil)
    return unless PressProof.can_sign?(current_user) and press_proof.can_be_signed?     
    message ||= ' Signer ce BAT'   
    link_to( image_tag( "/images/sign_16x16.png",
                        :alt => text = "Signaler que le BAT a été signé par le client",
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_sign_form_path(order, press_proof) )
  end
  
  def display_revoke_button(order, press_proof, message=nil)
    return unless PressProof.can_revoke?(current_user) and press_proof.can_be_revoked?  
    message ||= ' Annuler ce BAT malgrés la signature'      
    link_to( image_tag( "/images/cancel_16x16.png",
                        :alt => text = "Signaler que le BAT a été annulé aprés signature",
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_revoke_form_path(order, press_proof) )
  end
  
  def display_edit_button(order, press_proof, message=nil)
    return unless PressProof.can_edit?(current_user) and press_proof.can_be_edited?
    message ||= ' Modifier ce BAT'
    link_to( image_tag( "/images/edit_16x16.png",
                        :alt => text = "Modifier ce BAT",
                        :title => text ) + message,
             edit_order_commercial_step_press_proof_step_press_proof_path(order, press_proof) )
  end
  
  def display_show_button(order, press_proof, message=nil)
    return unless PressProof.can_view?(current_user)
    message ||= ' Voir ce BAT'
    link_to( image_tag( "/images/view_16x16.png",
                        :alt => text = "Voir ce BAT",
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_path(order, press_proof) )
  end
  
  def display_destroy_button(order, press_proof, message=nil)
    return unless PressProof.can_delete?(current_user) and press_proof.can_be_destroyed?
    message ||= ' Supprimer ce BAT'
    link_to( image_tag( "/images/delete_16x16.png",
                        :alt => text = "Supprimmer ce BAT",
                        :title => text ) + message,
             order_commercial_step_press_proof_step_press_proof_path(order, press_proof), :method => :delete, :confirm => "Êtes vous sûr?") 
  end
  
  def display_signed_press_proof_button(order, press_proof, message=nil)
    return unless PressProof.can_view?(current_user) and press_proof.signed? and press_proof.signed_press_proof
    message ||= ' Voir le BAT signé(PDF)'
    link_to( image_tag( "/images/mime_type_extensions/pdf_16x16.png",
                        :alt => alt = "Voir le PDF",
                        :title => alt ) + message,
             order_commercial_step_press_proof_step_press_proof_signed_press_proof_path(order, press_proof))
  end
  
  ## Dunning
  
  def display_dunning_add_button(order, press_proof, message=nil)
    return unless Dunning.can_add?(current_user) and press_proof.was_sended?
    message ||= ' Ajouter une relance'
    link_to( image_tag( "/images/relaunch_16x16.png",
                        :alt => text = "Ajouter une relance",
                        :title => text ) + message,
             new_order_commercial_step_press_proof_step_press_proof_dunning_path(order, press_proof))
  end
  
  def display_dunning_cancel_button(dunning)
    return unless Dunning.can_cancel?(current_user)
    press_proof = dunning.has_dunning
    order       = press_proof.order
    link_to( image_tag( "/images/cancel_16x16.png",
                        :alt => text = "Invalider cette relance",
                        :title => text ),
             order_commercial_step_press_proof_step_press_proof_dunning_cancel_path(order, press_proof, dunning),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def status_text(press_proof)
    case press_proof.status
      when PressProof::STATUS_CANCELLED
        'Annulé'
      when PressProof::STATUS_CONFIRMED
        'Validé'
      when PressProof::STATUS_SENDED
        'Envoyé'
      when PressProof::STATUS_SIGNED
        'Signé'
      when PressProof::STATUS_REVOKED
        'Annulé'
    end
  end
  
  # Permit to get a value for +rowspan+ into the press_proofs list
  # add 1 to the rowspan value, because the first line should be into the first +tr+ like:
  #
  # <table>                      | <table>
  #  <tr>                        |   <tr>
  #    <td rowspan='2' >2</td>   |     <td rowspan='3' >2</td>
  #    <td>1</tD>                |   </tr>
  #  </tr>                       |   <tr><td>1</td></tr>
  #  <tr><td>1</td></tr>         |   <tr><td>1</td></tr>
  #</table>                      | </table>
  #                            
  # should give :
  #     _______
  #    |   | 1 |
  #    | 2 |---|
  #    |   | 1 |
  #    '''''''''
  def get_row_value(product)
    product.press_proofs.collect(&:graphic_item_versions).flatten.size + 1 
  end
end
