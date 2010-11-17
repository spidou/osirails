module QuotesHelper
  
  def display_quotes(order)
    quotes = order.quotes.reject(&:new_record?)
    if quotes.empty?
      content_tag(:p, "Aucun devis n'a été trouvé")
    else
      render :partial => 'quotes/quotes_list', :object => quotes #.actives
    end
  end
  
  def quote_action_buttons(quote)
    order = quote.order
    html = []
    html << display_quote_show_button(order, quote)
    html << display_quote_edit_button(order, quote)
    html << display_quote_preview_button(order, quote)
    html << display_quote_show_pdf_button(order, quote)
    html << display_quote_order_form_button(order, quote)
    html << display_transform_quote_in_invoice_button(order, quote)
    
    html << display_quote_confirm_button(order, quote)
    html << display_quote_send_button(order, quote)
    html << display_quote_sign_button(order, quote)
    html << display_quote_cancel_button(order, quote)
    html << display_quote_delete_button(order, quote)
    html.compact
  end
  
  def display_quote_list_button(step, message = nil)
    return unless Quote.can_list?(current_user)
    link_to_unless_current(message || "Voir le(s) devis du dossier",
                           send(step.original_step.path),
                           'data-icon' => :index) {nil}
  end
  
  def display_quote_add_button(order, message = nil)
    return unless Quote.can_add?(current_user) and order.quotes.build.can_be_added?
    link_to_unless_current(message || "Nouveau devis",
                           new_order_commercial_step_quote_step_quote_path(order),
                           'data-icon' => :new) {nil}
  end
  
  def display_quote_show_button(order, quote, message = nil)
    return unless Quote.can_view?(current_user) and !quote.new_record?
    link_to_unless_current(message || "Voir",
                           order_commercial_step_quote_step_quote_path(order, quote),
                           'data-icon' => :show) {nil}
  end
  
  def display_quote_preview_button(order, quote, message = nil)
    return unless Quote.can_view?(current_user) and !quote.new_record? and !quote.can_be_downloaded?
    link_to(message || "Aperçu (PDF)",
            order_commercial_step_quote_step_quote_path(order, quote, :format => :pdf),
            'data-icon' => :preview)
  end
  
  def display_quote_show_pdf_button(order, quote, message = nil)
    return unless Quote.can_view?(current_user) and quote.can_be_downloaded?
    link_to(message || "Télécharger (PDF)",
            order_commercial_step_quote_step_quote_path(order, quote, :format => :pdf),
            'data-icon' => :download)
  end
  
  def display_quote_edit_button(order, quote, message = nil)
    return unless Quote.can_edit?(current_user) and quote.can_be_edited?
    link_to_unless_current(message || "Modifier",
                           edit_order_commercial_step_quote_step_quote_path(order, quote),
                           'data-icon' => :edit) {nil}
  end
  
  def display_quote_delete_button(order, quote, message = nil)
    return unless Quote.can_delete?(current_user) and quote.can_be_deleted?
    link_to(message || "Supprimer",
            order_commercial_step_quote_step_quote_path(order, quote),
            :method => :delete,
            :confirm => "Êtes vous sûr?",
            'data-icon' => :delete)
  end
  
  def display_quote_confirm_button(order, quote, message = nil)
    return unless Quote.can_confirm?(current_user) and quote.can_be_confirmed?
    link_to(message || "Valider",
            order_commercial_step_quote_step_quote_confirm_path(order, quote),
            :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le devis et vous ne pourrez plus le modifier.",
            'data-icon' => :confirm)
  end
  
  def display_quote_cancel_button(order, quote, message = nil)
    return unless Quote.can_cancel?(current_user) and quote.can_be_cancelled?
    link_to(message || "Annuler",
            order_commercial_step_quote_step_quote_cancel_path(order, quote),
            :confirm => "Êtes-vous sûr ?",
            'data-icon' => :cancel)
  end
  
  def display_quote_send_button(order, quote, message = nil)
    return unless Quote.can_send_to_customer?(current_user) and quote.can_be_sended?
    link_to(message || "Signaler l'envoi au client",
            order_commercial_step_quote_step_quote_send_form_path(order, quote),
            'data-icon' => :send)
  end
  
  def display_quote_sign_button(order, quote, message = nil)
    return unless Quote.can_sign?(current_user) and quote.can_be_signed?        
    link_to_unless_current(message || "Signaler la signature par le client",
                           order_commercial_step_quote_step_quote_sign_form_path(order, quote),
                           'data-icon' => :sign) {nil}
  end
  
  def display_quote_order_form_button(order, quote, message = nil)
    return unless Quote.can_view?(current_user) and quote.signed? and quote.order_form
    link_to(message || "Télécharger le \"#{quote.order_form_type.name.downcase}\"",
            order_commercial_step_quote_step_quote_order_form_path(order, quote),
            'data-icon' => :download)
  end
  
  def display_transform_quote_in_invoice_button(order, quote, message = nil)
    return unless Invoice.can_add?(current_user) and quote.was_signed? and order.invoices.build.can_create_deposit_invoice?
    link_to(message || "Transformer en facture d'acompte",
            new_order_invoicing_step_invoice_step_invoice_path(order, :invoice_type => 'deposit'),
            'data-icon' => :transform)
  end
  
  def display_add_free_quote_item_for(quote)
    button_to_function "Insérer une ligne de commentaire" do |page|
      page.insert_html :bottom, :quote_items_body, :partial => 'quote_items/quote_item',
                                                   :object  => quote.quote_items.build
      last_item = page[:quote_items_body].select('.free_quote_item').last.show.visual_effect :highlight
      
      page << "update_up_down_links_and_positions($('quote_items_body'))"
      page << "initialize_autoresize_text_areas()"
    end
  end
  
  def quote_status_text(quote)
    case quote.status
      when nil                      then 'Brouillon'
      when Quote::STATUS_CANCELLED  then 'Annulé'
      when Quote::STATUS_CONFIRMED  then 'Validé'
      when Quote::STATUS_SENDED     then 'Envoyé'
      when Quote::STATUS_SIGNED     then'Signé'
    end
  end
  
  def display_remaining_days_for(quote)
    delay = Date.today - quote.validity_date.to_date
    if delay < 0
      return "<br/>(J#{delay})"   # J-10
    elsif delay > 0
      return "<br/>(J+#{delay})"  # J+10
    elsif delay == 0
      return "<br/>(Jour J)"
    end  
  end
  
end
