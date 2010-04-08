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
  
  def display_transform_quote_in_invoice(quote)
    return unless Invoice.can_add?(current_user) and quote.order.invoices.build.can_create_deposit_invoice?
    img = image_tag( "next_24x24.png", :title => title = "Transformer en facture d'acompte", :alt => title )
    link_to( img, new_order_invoicing_step_invoice_step_invoice_path(:invoice_type => 'deposit') )
  end
  
  def display_transform_delivery_note_in_invoice(delivery_note)
    return unless Invoice.can_add?(current_user)
    order = delivery_note.order
    invoice = order.invoices.build
    html = []
    
    if invoice.can_create_status_invoice?
      invoice_type = 'status'
      invoice_type_title = "de situation"
      
      img = image_tag( "next_24x24.png", :title => title = "Transformer en facture #{invoice_type_title}", :alt => title )
      html << link_to( img, new_order_invoicing_step_invoice_step_invoice_path(order, :invoice_type => invoice_type, :delivery_note_ids => delivery_note.id) )
    end
    
    if invoice.can_create_balance_invoice?
      invoice_type = 'balance'
      invoice_type_title = "de solde"
      
      img = image_tag( "next_24x24.png", :title => title = "Transformer en facture #{invoice_type_title}", :alt => title )
      html << link_to( img, new_order_invoicing_step_invoice_step_invoice_path(order, :invoice_type => invoice_type) )
    end
    
    html.join("&nbsp;")
  end
  
  def display_invoice_action_buttons(order, invoice)
    html = []
    html << display_invoice_confirm_button(order, invoice, '')
    html << display_invoice_send_button(order, invoice, '')
    html << display_invoice_factoring_pay_button(order, invoice, '')
    html << display_invoice_factoring_recover_button(order, invoice, '')
    html << display_invoice_factoring_balance_pay_button(order, invoice, '')
    html << display_invoice_due_date_pay_button(order, invoice, '')
    html << display_invoice_totally_pay_button(order, invoice, '')
    html << display_invoice_cancel_button(order, invoice, '')
    html << display_invoice_abandon_button(order, invoice, '')
    
    html << display_invoice_show_pdf_button(order, invoice, '')
    html << display_invoice_show_button(order, invoice, '')
    html << display_invoice_edit_button(order, invoice, '')
    html << display_invoice_delete_button(order, invoice, '')
    html.compact.join("&nbsp;")
  end
  
  def display_invoice_list_button(step, message = nil)
    return unless Invoice.can_add?(current_user)
    text = "Voir les factures"
    message ||= " #{text}"
    link_to( image_tag( "list_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             send(step.original_step.path))
  end
  
  def display_invoice_add_button(order, message = nil)
    return unless Invoice.can_add?(current_user) and order.invoices.build.can_be_added?
    text = "Nouvelle facture"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_order_invoicing_step_invoice_step_invoice_path(order))
  end
  
  def display_invoice_show_button(order, invoice, message = nil)
    return unless Invoice.can_view?(current_user) and !invoice.new_record?
    text = "Voir cette facture"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_invoicing_step_invoice_step_invoice_path(order, invoice) )
  end
  
  def display_invoice_show_pdf_button(order, invoice, message = nil)
    return unless Invoice.can_view?(current_user)
    text = "Télécharger cette facture (PDF)"
    message ||= " #{text}"
    link_to( image_tag( "mime_type_extensions/pdf_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_invoicing_step_invoice_step_invoice_path(order, invoice, :format => :pdf) )
  end
  
  def display_invoice_edit_button(order, invoice, message = nil)
    return unless Invoice.can_edit?(current_user) and invoice.can_be_edited?
    text = "Modifier cette facture"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_order_invoicing_step_invoice_step_invoice_path(order, invoice) )
  end
  
  def display_invoice_delete_button(order, invoice, message = nil)
    return unless Invoice.can_delete?(current_user) and invoice.can_be_deleted?
    text = "Supprimer cette facture"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_invoicing_step_invoice_step_invoice_path(order, invoice), :method => :delete, :confirm => "Êtes vous sûr?")
  end
  
  def display_invoice_confirm_button(order, invoice, message = nil)
    return unless Invoice.can_confirm?(current_user) and invoice.can_be_confirmed?
    text = "Valider cette facture"
    message ||= " #{text}"
    link_to( image_tag( "confirm_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_confirm_path(order, invoice),
             :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour la facture et vous ne pourrez plus le modifier." )
  end
  
  def display_invoice_cancel_button(order, invoice, message = nil)
    return unless Invoice.can_cancel?(current_user) and invoice.can_be_cancelled?
    text = "Annuler cette facture"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_cancel_form_path(order, invoice),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_invoice_send_button(order, invoice, message = nil)
    return unless Invoice.can_send_to_customer?(current_user) and invoice.can_be_sended?
    text = "Signaler l'envoi de la facture au client"
    message ||= " #{text}"
    link_to( image_tag( "send_to_customer_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_send_form_path(order, invoice) )
  end
  
  def display_invoice_factoring_pay_button(order, invoice, message = nil)
    return unless Invoice.can_factoring_pay?(current_user) and invoice.can_be_factoring_paid?
    text = "Signaler le règlement partiel du Factor"
    message ||= " #{text}"
    link_to( image_tag( "factoring_pay_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_factoring_pay_form_path(order, invoice) )
  end
  
  def display_invoice_factoring_recover_button(order, invoice, message = nil)
    return unless Invoice.can_factoring_recover?(current_user) and invoice.can_be_factoring_recovered?
    text = "Signaler le définancement par le Factor"
    message ||= " #{text}"
    link_to( image_tag( "factoring_recover_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_factoring_recover_form_path(order, invoice) )
  end
  
  def display_invoice_factoring_balance_pay_button(order, invoice, message = nil)
    return unless Invoice.can_factoring_balance_pay?(current_user) and invoice.can_be_factoring_balance_paid?
    text = "Signaler le règlement du solde par le Factor"
    message ||= " #{text}"
    link_to( image_tag( "factoring_balance_pay_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_factoring_balance_pay_form_path(order, invoice) )
  end
  
  def display_invoice_due_date_pay_button(order, invoice, message = nil)
    return unless Invoice.can_due_date_pay?(current_user) and invoice.can_be_due_date_paid?
    text = "Signaler le règlement d'une échéance"
    message ||= " #{text}"
    link_to( image_tag( "due_date_pay_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_due_date_pay_form_path(order, invoice) )
  end
  
  def display_invoice_totally_pay_button(order, invoice, message = nil)
    return unless Invoice.can_totally_pay?(current_user) and invoice.can_be_totally_paid?
    text = "Signaler le règlement du solde"
    message ||= " #{text}"
    link_to( image_tag( "totally_pay_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_totally_pay_form_path(order, invoice) )
  end
  
  def display_invoice_abandon_button(order, invoice, message = nil)
    return unless Invoice.can_abandon?(current_user) and invoice.can_be_abandoned?
    text = "Signaler cette facture \"sans suite\""
    message ||= " #{text}"
    link_to( image_tag( "abandon_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_invoicing_step_invoice_step_invoice_abandon_form_path(order, invoice) )
  end
  
  def status_text(invoice)
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
  
end
