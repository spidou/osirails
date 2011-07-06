module DeliveryNotesHelper
  
  def display_delivery_notes(order)
    delivery_notes = order.delivery_notes.reject(&:new_record?)
    if delivery_notes.empty?
      content_tag(:p, "Aucun bon de livraison n'a été trouvé")
    else
      render :partial => 'delivery_notes/delivery_notes', :object => delivery_notes
    end
  end
  
  def delivery_note_action_buttons(delivery_note)
    order = delivery_note.order
    html = []
    html << display_delivery_note_show_button(order, delivery_note)
    html << display_delivery_note_edit_button(order, delivery_note)
    html << display_delivery_note_preview_button(order, delivery_note)
    html << display_delivery_note_show_pdf_button(order, delivery_note)
    html << display_delivery_note_download_attachment_button(order, delivery_note)
    html << display_transform_delivery_note_in_status_invoice_button(order, delivery_note)
    html << display_transform_delivery_note_in_balance_invoice_button(order, delivery_note)
    
    html << display_delivery_note_confirm_button(order, delivery_note)
    html << display_delivery_note_schedule_button(order, delivery_note)
    html << display_delivery_note_realize_button(order, delivery_note)
    html << display_delivery_note_sign_button(order, delivery_note)
    html << display_delivery_note_cancel_button(order, delivery_note)
    html << display_delivery_note_delete_button(order, delivery_note)
    html.compact
  end
  
  def display_delivery_note_add_button(order, message = nil)
    return unless DeliveryNote.can_add?(current_user) and order.delivery_notes.build.can_be_added?
    link_to(message || "Nouveau BL",
            new_order_delivering_step_delivery_step_delivery_note_path(order),
            'data-icon' => :new)
  end
  
  def display_delivery_note_show_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_view?(current_user) and !delivery_note.new_record?
    link_to_unless_current(message || "Voir",
                           order_delivering_step_delivery_step_delivery_note_path(order, delivery_note),
                           'data-icon' => :show) {nil}
  end
  
  def display_delivery_note_preview_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_view?(current_user) and !delivery_note.new_record? and !delivery_note.can_be_downloaded?
    link_to(message || "Aperçu (PDF)",
            order_delivering_step_delivery_step_delivery_note_path(order, delivery_note, :format => :pdf),
            'data-icon' => :preview)
  end
  
  def display_delivery_note_show_pdf_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_view?(current_user) and delivery_note.can_be_downloaded?
    link_to(message || "Télécharger (PDF)",
            order_delivering_step_delivery_step_delivery_note_path(order, delivery_note, :format => :pdf),
            'data-icon' => :download)
  end
  
  def display_delivery_note_edit_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_edit?(current_user) and delivery_note.can_be_edited?
    link_to_unless_current(message || "Modifier",
                           edit_order_delivering_step_delivery_step_delivery_note_path(order, delivery_note),
                           'data-icon' => :edit) {nil}
  end
  
  def display_delivery_note_delete_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_delete?(current_user) and delivery_note.can_be_destroyed?
    link_to(message || "Supprimer",
            order_delivering_step_delivery_step_delivery_note_path(order, delivery_note),
            :method => :delete,
            :confirm => "Êtes vous sûr?",
            'data-icon' => :delete)
  end
  
  def display_delivery_note_confirm_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_confirm?(current_user) and delivery_note.can_be_confirmed?
    link_to(message || "Valider",
            order_delivering_step_delivery_step_delivery_note_confirm_path(order, delivery_note),
            :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le bon de livraison et vous ne pourrez plus le modifier.",
            'data-icon' => :confirm)
  end
  
  def display_delivery_note_schedule_button(order, delivery_note, message = nil)
    return unless DeliveryIntervention.can_add?(current_user) and DeliveryIntervention.can_edit?(current_user) and delivery_note.can_be_scheduled?
    link_to_unless_current(message || "Planifier une intervention",
                           order_delivering_step_delivery_step_delivery_note_schedule_form_path(order, delivery_note),
                           'data-icon' => :schedule) {nil}
  end
  
  def display_delivery_note_realize_button(order, delivery_note, message = nil)
    return unless DeliveryIntervention.can_edit?(current_user) and delivery_note.can_be_realized?
    link_to_unless_current(message || "Signaler la réalisation de l'intervention",
                           order_delivering_step_delivery_step_delivery_note_realize_form_path(order, delivery_note),
                           'data-icon' => :realize) {nil}
  end
  
  def display_delivery_note_cancel_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_cancel?(current_user) and delivery_note.can_be_cancelled?
    link_to(message || "Annuler",
            order_delivering_step_delivery_step_delivery_note_cancel_path(order, delivery_note),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :cancel)
  end
  
  def display_delivery_note_sign_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_sign?(current_user) and delivery_note.can_be_signed?
    link_to_unless_current(message || "Signaler la signature par le client",
                           order_delivering_step_delivery_step_delivery_note_sign_form_path(order, delivery_note),
                           'data-icon' => :sign) {nil}
  end
  
  def display_delivery_note_download_attachment_button(order, delivery_note, message = nil)
    return unless DeliveryNote.can_view?(current_user) and delivery_note.was_signed?
    link_to(message || "Télécharger le BL signé (PDF)",
            order_delivering_step_delivery_step_delivery_note_attachment_path(order, delivery_note),
            'data-icon' => :download)
  end
  
  def display_transform_delivery_note_in_status_invoice_button(order, delivery_note, delivery_note_ids = nil, message = nil)
    return unless Invoice.can_add?(current_user) and delivery_note.was_signed? and order.invoices.build.can_create_status_invoice?
    delivery_note_ids ||= [delivery_note.id]
    link_to(message || "Transformer en facture de situation",
            new_order_invoicing_step_invoice_step_invoice_path(order, :invoice_type => 'status', :delivery_note_ids => delivery_note_ids),
            'data-icon' => :transform)
  end
  
  def display_transform_delivery_note_in_balance_invoice_button(order, delivery_note, message = nil)
    return unless Invoice.can_add?(current_user) and delivery_note.was_signed? and order.invoices.build.can_create_balance_invoice?
    link_to(message || "Transformer en facture de solde",
            new_order_invoicing_step_invoice_step_invoice_path(order, :invoice_type => 'balance'),
            'data-icon' => :transform)
  end
  
  def delivery_note_status_text(delivery_note)
    case delivery_note.status
      when nil                            then 'Brouillon'
      when DeliveryNote::STATUS_CANCELLED then 'Annulé'
      when DeliveryNote::STATUS_CONFIRMED then 'Validé'
      when DeliveryNote::STATUS_SIGNED    then 'Signé'
    end
  end
  
end
