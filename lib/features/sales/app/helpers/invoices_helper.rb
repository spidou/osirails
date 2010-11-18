module InvoicesHelper
  
  def display_transition_table_for_deposit_invoice(order)
    return unless Invoice.can_add?(current_user) and order.invoices.build.can_create_deposit_invoice?
    render :partial => 'invoices/transition_table_for_deposit_invoice', :object => order.signed_quote
  end
  
  def display_transition_table_for_other_invoices(order)
    return unless Invoice.can_add?(current_user) and ( order.invoices.build.can_create_status_invoice? or order.invoices.build.can_create_balance_invoice? )
    render :partial => 'invoices/transition_table_for_other_invoices', :object => order.unbilled_delivery_notes
  end
  
  def display_invoices(order)
    invoices = order.invoices.reject(&:new_record?)
    if invoices.empty?
      content_tag(:p, "Aucune facture n'a été trouvée")
    else
      render :partial => 'invoices/invoices_list', :object => invoices #.actives
    end
  end
  
  def invoice_action_buttons(invoice)
    order = invoice.order
    html = []
    html << display_invoice_show_button(order, invoice)
    html << display_invoice_edit_button(order, invoice)
    html << display_invoice_preview_button(order, invoice)
    html << display_invoice_show_pdf_button(order, invoice)
    
    html << display_invoice_confirm_button(order, invoice)
    html << display_invoice_send_button(order, invoice)
    html << display_invoice_factoring_pay_button(order, invoice)
    html << display_invoice_factoring_recover_button(order, invoice)
    html << display_invoice_factoring_balance_pay_button(order, invoice)
    html << display_invoice_due_date_pay_button(order, invoice)
    html << display_invoice_totally_pay_button(order, invoice)
    html << display_invoice_cancel_button(order, invoice)
    html << display_invoice_abandon_button(order, invoice)
    html << display_invoice_delete_button(order, invoice)
    html.compact
  end
  
  def display_invoice_add_button(order, message = nil)
    return unless Invoice.can_add?(current_user) and ( order.invoices.build(:invoice_type_id => InvoiceType.find_by_name(Invoice::DEPOSITE_INVOICE).id).can_be_added? or
                                                       order.invoices.build(:invoice_type_id => InvoiceType.find_by_name(Invoice::STATUS_INVOICE).id).can_be_added? or
                                                       order.invoices.build(:invoice_type_id => InvoiceType.find_by_name(Invoice::BALANCE_INVOICE).id).can_be_added? or
                                                       order.invoices.build(:invoice_type_id => InvoiceType.find_by_name(Invoice::ASSET_INVOICE).id).can_be_added? )
    link_to_unless_current(message || "Nouvelle facture",
                           new_order_invoicing_step_invoice_step_invoice_path(order),
                           'data-icon' => :new) {nil}
  end
  
  def display_invoice_show_button(order, invoice, message = nil)
    return unless Invoice.can_view?(current_user) and !invoice.new_record?
    link_to_unless_current(message || "Voir",
                           order_invoicing_step_invoice_step_invoice_path(order, invoice),
                           'data-icon' => :show) {nil}
  end
  
  def display_invoice_preview_button(order, invoice, message = nil)
    return unless Invoice.can_view?(current_user) and !invoice.new_record? and !invoice.can_be_downloaded?
    link_to(message || "Aperçu (PDF)",
            order_invoicing_step_invoice_step_invoice_path(order, invoice, :format => :pdf),
            'data-icon' => :preview)
  end
  
  def display_invoice_show_pdf_button(order, invoice, message = nil)
    return unless Invoice.can_view?(current_user) and invoice.can_be_downloaded?
    link_to(message || "Télécharger (PDF)",
            order_invoicing_step_invoice_step_invoice_path(order, invoice, :format => :pdf),
            'data-icon' => :download)
  end
  
  def display_invoice_edit_button(order, invoice, message = nil)
    return unless Invoice.can_edit?(current_user) and invoice.can_be_edited?
    link_to_unless_current(message || "Modifier",
                           edit_order_invoicing_step_invoice_step_invoice_path(order, invoice),
                           'data-icon' => :edit) {nil}
  end
  
  def display_invoice_delete_button(order, invoice, message = nil)
    return unless Invoice.can_delete?(current_user) and invoice.can_be_deleted?
    link_to(message || "Supprimer",
            order_invoicing_step_invoice_step_invoice_path(order, invoice),
            :method => :delete,
            :confirm => "Êtes vous sûr?",
            'data-icon' => :delete)
  end
  
  def display_invoice_confirm_button(order, invoice, message = nil)
    return unless Invoice.can_confirm?(current_user) and invoice.can_be_confirmed?
    link_to(message || "Valider",
            order_invoicing_step_invoice_step_invoice_confirm_path(order, invoice),
            :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour la facture et vous ne pourrez plus le modifier.",
            'data-icon' => :confirm)
  end
  
  def display_invoice_cancel_button(order, invoice, message = nil)
    return unless Invoice.can_cancel?(current_user) and invoice.can_be_cancelled?
    link_to_unless_current(message || "Annuler",
                           order_invoicing_step_invoice_step_invoice_cancel_form_path(order, invoice),
                           :confirm => "Êtes-vous sûr ?",
                           'data-icon' => :cancel) {nil}
  end
  
  def display_invoice_send_button(order, invoice, message = nil)
    return unless Invoice.can_send_to_customer?(current_user) and invoice.can_be_sended?
    link_to_unless_current(message || "Signaler l'envoi au client",
                           order_invoicing_step_invoice_step_invoice_send_form_path(order, invoice),
                           'data-icon' => :send) {nil}
  end
  
  def display_invoice_factoring_pay_button(order, invoice, message = nil)
    return unless Invoice.can_factoring_pay?(current_user) and invoice.can_be_factoring_paid?
    link_to_unless_current(message || "Signaler le règlement partiel du Factor",
                           order_invoicing_step_invoice_step_invoice_factoring_pay_form_path(order, invoice),
                           'data-icon' => :factoring_pay) {nil}
  end
  
  def display_invoice_factoring_recover_button(order, invoice, message = nil)
    return unless Invoice.can_factoring_recover?(current_user) and invoice.can_be_factoring_recovered?
    link_to_unless_current(message || "Signaler le définancement par le Factor",
                           order_invoicing_step_invoice_step_invoice_factoring_recover_form_path(order, invoice),
                           'data-icon' => :factoring_recover) {nil}
  end
  
  def display_invoice_factoring_balance_pay_button(order, invoice, message = nil)
    return unless Invoice.can_factoring_balance_pay?(current_user) and invoice.can_be_factoring_balance_paid?
    link_to_unless_current(message || "Signaler le règlement du solde par le Factor",
                           order_invoicing_step_invoice_step_invoice_factoring_balance_pay_form_path(order, invoice),
                           'data-icon' => :factoring_balance_pay) {nil}
  end
  
  def display_invoice_due_date_pay_button(order, invoice, message = nil)
    return unless Invoice.can_due_date_pay?(current_user) and invoice.can_be_due_date_paid?
    link_to_unless_current(message || "Signaler le règlement d'une échéance",
                           order_invoicing_step_invoice_step_invoice_due_date_pay_form_path(order, invoice),
                           'data-icon' => :due_date_pay) {nil}
  end
  
  def display_invoice_totally_pay_button(order, invoice, message = nil)
    return unless Invoice.can_totally_pay?(current_user) and invoice.can_be_totally_paid?
    link_to_unless_current(message || "Signaler le règlement du solde",
                           order_invoicing_step_invoice_step_invoice_totally_pay_form_path(order, invoice),
                           'data-icon' => :totally_pay) {nil}
  end
  
  def display_invoice_abandon_button(order, invoice, message = nil)
    return unless Invoice.can_abandon?(current_user) and invoice.can_be_abandoned?
    link_to_unless_current(message || "Signaler cette facture \"sans suite\"",
                           order_invoicing_step_invoice_step_invoice_abandon_form_path(order, invoice),
                           'data-icon' => :abandon) {nil}
  end
  
  def invoice_status_text(invoice)
    case invoice.status
      when nil                                    then "Brouillon"
      when Invoice::STATUS_CONFIRMED              then "Validée"
      when Invoice::STATUS_CANCELLED              then "Annulée"
      when Invoice::STATUS_SENDED                 then "Envoyée au client"
      when Invoice::STATUS_ABANDONED              then "Abandonée (déclarée \"sans suite\")"
      when Invoice::STATUS_DUE_DATE_PAID          then "Payée partiellement par le CLIENT"
      when Invoice::STATUS_TOTALLY_PAID           then "Payée en totalité par le CLIENT"
      when Invoice::STATUS_FACTORING_PAID         then "Payée partiellement par le FACTOR"
      when Invoice::STATUS_FACTORING_RECOVERED    then "Définancée par le FACTOR"
      when Invoice::STATUS_FACTORING_BALANCE_PAID then "Payée totallement par le FACTOR"
    end
  end
  
  def display_delay_of_paiment_for(invoice)
    delay = invoice.due_dates.last.date - invoice.sended_on if invoice.sended_on
    "#{delay} jour(s)"
  end
  
  def display_delay_of_upcoming_due_date_paiment_for(invoice)
    return "" unless invoice.upcoming_due_date
    
    delay = Date.today - invoice.upcoming_due_date.date
    if delay < 0
      return " (J#{delay})"   # J-10
    elsif delay > 0
      return " (J+#{delay})"  # J+10
    elsif delay == 0
      return " (Jour J)"
    end
  end
  
  def display_delivery_notes_references_for(invoice)
    invoice.delivery_notes.collect(&:reference).join("<br/>")
  end
  
  def display_state_of_delivery_notes_references_for(invoice)
    invoice.delivery_notes.collect{ |n| n.signed? ? "Oui" : "Non" }.join("<br/>")
  end
  
end
