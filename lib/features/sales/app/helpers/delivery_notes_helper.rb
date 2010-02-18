module DeliveryNotesHelper
  
  def display_delivery_note_add_button
    if @order.signed_quote
      content_tag(:p, link_to("Nouveau bon de livraison / installation", new_order_pre_invoicing_step_delivery_step_delivery_note_path))
    else
      content_tag(:span, "Vous ne pouvez pas créer de bon de livraison tant que le devis n'est pas signé", :class => :warning)
    end
  end
  
  def order_pre_invoicing_step_delivery_step_delivery_note_link_overrided(order, delivery_note, options = {})
    return unless DeliveryNote.can_view?(current_user)
    default_text = "Voir le bon de livraison#{" (PDF)" if options[:options] and options[:options][:format] == :pdf}"
    default_image_src = ( options[:options] and options[:options][:format] == :pdf ) ? "/images/mime_type_extensions/pdf_16x16.png" : "/images/view_16x16.png"
    
    options = { :link_text => default_text,
                :image_tag => image_tag(default_image_src, :alt => default_text, :title => default_text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], order_pre_invoicing_step_delivery_step_delivery_note_path(order, delivery_note, options[:options] || {})
  end
  
  def edit_order_pre_invoicing_step_delivery_step_delivery_note_link_overrided(order, delivery_note, options = {})
    return unless DeliveryNote.can_edit?(current_user) and delivery_note.can_be_edited?
    options = { :link_text => text = "Modifier le bon de livraison",
                :image_tag => image_tag("/images/edit_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], edit_order_pre_invoicing_step_delivery_step_delivery_note_path(order, delivery_note)
  end
  
  def delete_order_pre_invoicing_step_delivery_step_delivery_note_link_overrided(order, delivery_note, options = {})
    return unless DeliveryNote.can_delete?(current_user) and delivery_note.can_be_destroyed?
    options = { :link_text => text = "Supprimer le devis",
                :image_tag => image_tag("/images/delete_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to options[:image_tag] + options[:link_text], order_pre_invoicing_step_delivery_step_delivery_note_path(order, delivery_note), :method => :delete, :confirm => "Are you sure?"
  end
  
  def display_additional_actions_delivery_note_button(order, delivery_note)
    html = []
    html << display_delivery_note_confirm_button(order, delivery_note)
    html << display_delivery_note_realize_button(order, delivery_note)
    html << display_delivery_note_schedule_button(order, delivery_note)
    html << display_delivery_note_download_attachment_button(order, delivery_note)
    html << display_delivery_note_sign_button(order, delivery_note)
    html << display_delivery_note_cancel_button(order, delivery_note)
    html.compact.join("&nbsp;")
  end
  
  def display_delivery_note_confirm_button(order, delivery_note)
    return unless DeliveryNote.can_confirm?(current_user) and delivery_note.can_be_confirmed?
    link_to( image_tag( "/images/confirm_16x16.png",
                        :alt => text = "Valider ce bon de livraison",
                        :title => text ),
             order_pre_invoicing_step_delivery_step_delivery_note_confirm_path(order, delivery_note),
             :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le bon de livraison et vous ne pourrez plus le modifier." )
  end
  
  def display_delivery_note_schedule_button(order, delivery_note)
    return unless DeliveryIntervention.can_add?(current_user) and DeliveryIntervention.can_edit?(current_user) and delivery_note.can_be_scheduled?
    link_to( image_tag( "schedule_16x16.png",
                        :alt => text = "Planifier une intervention pour ce bon de livraison",
                        :title => text ),
             order_pre_invoicing_step_delivery_step_delivery_note_schedule_form_path(order, delivery_note) )
  end
  
  def display_delivery_note_realize_button(order, delivery_note)
    return unless DeliveryIntervention.can_edit?(current_user) and delivery_note.can_be_realized?
    link_to( image_tag( "realize_16x16.png",
                        :alt => text = "Signaler la réalisation d'une intervention pour ce bon de livraison",
                        :title => text ),
             order_pre_invoicing_step_delivery_step_delivery_note_realize_form_path(order, delivery_note) )
  end
  
  def display_delivery_note_cancel_button(order, delivery_note)
    return unless DeliveryNote.can_cancel?(current_user) and delivery_note.can_be_cancelled?
    link_to( image_tag( "/images/cancel_16x16.png",
                        :alt => text = "Annulé ce bon de livraison",
                        :title => text ),
             order_pre_invoicing_step_delivery_step_delivery_note_cancel_path(order, delivery_note),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_delivery_note_sign_button(order, delivery_note)
    return unless DeliveryNote.can_sign?(current_user) and delivery_note.can_be_signed?        
    link_to( image_tag( "/images/sign_16x16.png",
                        :alt => text = "Signaler que le bon de livraison a été signé par le client",
                        :title => text ),
             order_pre_invoicing_step_delivery_step_delivery_note_sign_form_path(order, delivery_note) )
  end
  
  def display_delivery_note_download_attachment_button(order, delivery_note)
    return unless DeliveryNote.can_view?(current_user) and delivery_note.was_signed?
    link_to( image_tag( "/images/mime_type_extensions/pdf_16x16.png",
                        :alt => text = "Télécharger le bon de livraison signé (PDF)",
                        :title => text ),
             order_pre_invoicing_step_delivery_step_delivery_note_attachment_path(order, delivery_note) )
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
