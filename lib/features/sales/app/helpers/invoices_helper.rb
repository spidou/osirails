module InvoicesHelper
  
  def display_transition_table_for_deposit_invoice(order)
    return unless order.signed_quote and !order.deposit_invoice
    render :partial => 'invoices/transition_table_for_deposit_invoice', :object => order.signed_quote
  end
  
  def display_transition_table_for_other_invoices(order)
    return if order.unbilled_delivery_notes.empty?
    render :partial => 'invoices/display_transition_table_for_other_invoices', :collection => order.unbilled_delivery_notes
  end
  
  def display_invoices(order)
    #return if order.invoices.actives.empty?
    if order.invoices.empty?
      content_tag(:p, "Aucune facture n'a été trouvée")
    else
      render :partial => 'invoices/invoices_list', :object => order.invoices #.actives
    end
  end
  
  def display_transform_quote_in_invoice(quote)
    return unless Invoice.can_add?(current_user)
    img = image_tag( "next_24x24.png", :title => title = "Transformer en facture d'acompte", :alt => title )
    link_to( img, new_order_invoicing_step_invoice_step_invoice_path(:invoice_type => 'deposit') )
  end
  
  def new_order_invoicing_step_invoice_step_invoice_link_overrided(order, options = {})
    return unless Invoice.can_add?(current_user)
    options = { :link_text => text = "Nouvelle facture",
                :image_tag => image_tag("/images/add_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to "#{options[:image_tag]} #{options[:link_text]}", new_order_invoicing_step_invoice_step_invoice_path(order)
  end
  
  def order_invoicing_step_invoice_step_invoice_link_overrided(order, invoice, options = {})
    return unless Invoice.can_view?(current_user)
    default_text = "Voir la facture#{" (PDF)" if options[:options] and options[:options][:format] == :pdf}"
    default_image_src = ( options[:options] and options[:options][:format] == :pdf ) ? "/images/mime_type_extensions/pdf_16x16.png" : "/images/view_16x16.png"
    
    options = { :link_text => default_text,
                :image_tag => image_tag(default_image_src, :alt => default_text, :title => default_text)
              }.merge(options)
    link_to "#{options[:image_tag]} #{options[:link_text]}", order_invoicing_step_invoice_step_invoice_path(order, invoice, options[:options] || {})
  end
  
  def edit_order_invoicing_step_invoice_step_invoice_link_overrided(order, invoice, options = {})
    return unless Invoice.can_edit?(current_user)
    options = { :link_text => text = "Modifier la facture",
                :image_tag => image_tag("/images/edit_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to "#{options[:image_tag]} #{options[:link_text]}", edit_order_invoicing_step_invoice_step_invoice_path(order, invoice)
  end
  
  def delete_order_invoicing_step_invoice_step_invoice_link_overrided(order, invoice, options = {})
    return unless Invoice.can_delete?(current_user)
    options = { :link_text => text = "Supprimer la facture",
                :image_tag => image_tag("/images/delete_16x16.png", :alt => text, :title => text)
              }.merge(options)
    link_to "#{options[:image_tag]} #{options[:link_text]}", order_invoicing_step_invoice_step_invoice_path(order, invoice), :method => :delete, :confirm => "Are you sure?"
  end
  
  def display_invoice_action_buttons(order, invoice)
    html = []
    html << display_invoice_confirm_button(order, invoice)
    html << display_invoice_send_button(order, invoice)
    html << display_invoice_factoring_pay_button(order, invoice)
    html << display_invoice_factoring_recover_button(order, invoice)
    html << display_invoice_factoring_balance_pay_button(order, invoice)
    html << display_invoice_due_date_pay_button(order, invoice)
    html << display_invoice_totally_pay_button(order, invoice)
    html << display_invoice_cancel_button(order, invoice)
    html << display_invoice_abandon_button(order, invoice)
    
    html << display_invoice_show_pdf_button(order, invoice)
    html << display_invoice_show_button(order, invoice)
    html << display_invoice_edit_button(order, invoice)
    html << display_invoice_delete_button(order, invoice)
    html.compact.join("&nbsp;")
  end
  
  def display_invoice_show_pdf_button(order, invoice)
    return unless Invoice.can_view?(current_user) and !invoice.uncomplete?
    order_invoicing_step_invoice_step_invoice_link_overrided(order, invoice, :link_text => "", :options => { :format => :pdf })
  end
  
  def display_invoice_show_button(order, invoice)
    return unless Invoice.can_view?(current_user)
    order_invoicing_step_invoice_step_invoice_link_overrided(order, invoice, :link_text => "")
  end
  
  def display_invoice_edit_button(order, invoice)
    return unless Invoice.can_edit?(current_user) and invoice.can_be_edited?
    edit_order_invoicing_step_invoice_step_invoice_link_overrided(order, invoice, :link_text => "")
  end
  
  def display_invoice_delete_button(order, invoice)
    return unless Invoice.can_delete?(current_user) and invoice.can_be_deleted?
    delete_order_invoicing_step_invoice_step_invoice_link_overrided(order, invoice, :link_text => "")
  end
  
  def display_invoice_confirm_button(order, invoice)
    return unless Invoice.can_confirm?(current_user) and invoice.can_be_confirmed?
    link_to( image_tag( "/images/confirm_16x16.png",
                        :alt    => text = "Valider cette facture",
                        :title  => text ),
             order_invoicing_step_invoice_step_invoice_confirm_path(order, invoice),
             :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour la facture et vous ne pourrez plus le modifier." )
  end
  
  def display_invoice_cancel_button(order, invoice)
    return unless Invoice.can_cancel?(current_user) and invoice.can_be_cancelled?
    link_to( image_tag( "/images/cancel_16x16.png",
                        :alt    => text = "Annuler cette facture",
                        :title  => text ),
             order_invoicing_step_invoice_step_invoice_cancel_form_path(order, invoice),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_invoice_send_button(order, invoice)
    return unless Invoice.can_send_to_customer?(current_user) and invoice.can_be_sended?        
    link_to( image_tag( "/images/send_to_customer_16x16.png",
                        :alt    => text = "Signaler que la facture a été envoyée au client",
                        :title  => text ),
             order_invoicing_step_invoice_step_invoice_send_form_path(order, invoice) )
  end
  
  def display_invoice_factoring_pay_button(order, invoice)
    return unless Invoice.can_factoring_pay?(current_user) and invoice.can_be_factoring_paid?
    link_to( image_tag( "/images/factoring_pay_16x16.png",
                        :alt    => text = "Signaler le règlement de la facture par le FACTOR",
                        :title  => text ),
             order_invoicing_step_invoice_step_invoice_factoring_pay_form_path(order, invoice) )
  end
  
  def display_invoice_factoring_recover_button(order, invoice)
    return unless Invoice.can_factoring_recover?(current_user) and invoice.can_be_factoring_recovered?
    link_to( image_tag( "/images/factoring_recover_16x16.png",
                        :alt    => text = "Signaler le définancement de la facture par le FACTOR",
                        :title  => text ),
             order_invoicing_step_invoice_step_invoice_factoring_recover_form_path(order, invoice) )
  end
  
  def display_invoice_factoring_balance_pay_button(order, invoice)
    return unless Invoice.can_factoring_balance_pay?(current_user) and invoice.can_be_factoring_balance_paid?
    link_to( image_tag( "/images/factoring_balance_pay_16x16.png",
                        :alt    => text = "Signaler le paiement du solde de la facture par le FACTOR",
                        :title  => text ),
             order_invoicing_step_invoice_step_invoice_factoring_balance_pay_form_path(order, invoice) )
  end
  
  def display_invoice_due_date_pay_button(order, invoice)
    return unless Invoice.can_due_date_pay?(current_user) and invoice.can_be_due_date_paid?
    link_to( image_tag( "/images/due_date_pay_16x16.png",
                        :alt    => text = "Signaler le règlement partiel de la facture par le CLIENT",
                        :title  => text ),
             order_invoicing_step_invoice_step_invoice_due_date_pay_form_path(order, invoice) )
  end
  
  def display_invoice_totally_pay_button(order, invoice)
    return unless Invoice.can_totally_pay?(current_user) and invoice.can_be_totally_paid?
    link_to( image_tag( "/images/totally_pay_16x16.png",
                        :alt    => text = "Signaler le règlement total (ou solde) de la facture par le CLIENT",
                        :title  => text ),
             order_invoicing_step_invoice_step_invoice_totally_pay_form_path(order, invoice) )
  end
  
  def display_invoice_abandon_button(order, invoice)
    return unless Invoice.can_abandon?(current_user) and invoice.can_be_abandoned?        
    link_to( image_tag( "/images/abandon_16x16.png",
                        :alt    => text = "Signaler que la facture est \"sans suite\" (ou abandonée)",
                        :title  => text ),
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
