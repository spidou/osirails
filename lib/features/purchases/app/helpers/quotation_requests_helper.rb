module QuotationRequestsHelper
  def generate_quotation_request_contextual_menu_partial(quotation_request = nil)
    render :partial => 'quotation_requests/contextual_menu', :object => quotation_request
  end
  
  def display_quotation_request_confirm_button(quotation_request, message = nil)
    return unless quotation_request.can_be_confirmed?
    text = "Confirmer la demande de devis"
    message ||= " #{text}"
    link_to( image_tag( "tick_16x16.png",
                        :alt => text,
                        :title => text ) + message,
                        quotation_request_confirm_path(quotation_request),
                        :method => :put,
                        :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour la demande de devis et vous ne pourrez plus la modifier.")
  end
  
  def display_quotation_request_add_button(message = nil)
    return unless QuotationRequest.can_add?(current_user)
    text = "Nouvelle demande de devis"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_quotation_request_path)
  end
  
  def display_quotation_request_show_button(quotation_request, message = nil)
    return unless QuotationRequest.can_view?(current_user) and !quotation_request.new_record?
    text = "Voir cette demande de devis"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             quotation_request_path(quotation_request) )
  end

  def display_quotation_request_edit_button(quotation_request, message = nil)
    return unless QuotationRequest.can_view?(current_user) and quotation_request.can_be_edited?
    text = "Modifier cette demande de devis"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_quotation_request_path(quotation_request) )
  end
  
  def display_quotation_request_delete_button(quotation_request, message = nil)
    return unless QuotationRequest.can_delete?(current_user) and quotation_request.can_be_destroyed?
    text = "Supprimer cette demande de devis"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             quotation_request, :method => :delete, :confirm => "Êtes vous sûr?")
  end

  def display_quotation_request_cancel_button(quotation_request, message = nil)
    return unless QuotationRequest.can_cancel?(current_user) and quotation_request.can_be_cancelled?
    text = "Annuler cette demande de devis"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             quotation_request_cancel_form_path(quotation_request),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_quotation_request_review_button(quotation_request, message = nil)
    return unless quotation_request.can_be_reviewed?
    text = "Revoir cette demande de devis"
    message ||= " #{text}"
    link_to( image_tag( "review_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             quotation_request_review_path(quotation_request) )
  end
  
  def display_quotation_request_make_copy_button(quotation_request, message = nil)
    text = "Copier cette demande de devis"
    message ||= " #{text}"
    link_to( image_tag( "copy_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             quotation_request_make_copy_path(quotation_request) )
  end
  
  def display_quotation_request_send_to_another_supplier_button(quotation_request, message = nil)
    return unless quotation_request.can_be_sent_to_another_supplier?
    text = "Faire une copie pour un autre fournisseur"
    message ||= " #{text}"
    link_to( image_tag( "send_to_another_supplier_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             quotation_request_send_to_another_supplier_path(quotation_request) )
  end
  
  def display_quotation_request_reference(quotation_request)
    return "" unless quotation_request.reference
    link_to( quotation_request.reference, quotation_request_path(quotation_request) )
  end
  
  def display_quotation_request_supplier_name(quotation_request)
    link_to quotation_request.supplier.name, supplier_path(quotation_request.supplier)
  end
  
  def display_quotation_request_employee_name(quotation_request)
    return "" unless quotation_request.employee
    link_to quotation_request.employee.fullname, employee_path(quotation_request.employee)
  end
  
  def display_quotation_request_current_status(quotation_request)
    if quotation_request.was_cancelled?
      "Annulée"
    elsif quotation_request.was_revoked?
      "Sans suite"
    elsif quotation_request.was_terminated?
      "Terminée"
    elsif quotation_request.was_confirmed?
      "Confirmée"
    elsif quotation_request.was_drafted?
      "Brouillon"
    end
  end
  
  def display_quotation_request_purchase_requests_references(quotation_request)
    html = []
    quotation_request.existing_and_free_quotation_request_supplies do |qrs|
      qrs.purchase_request_supplies.each{ |prs| html << link_to(prs.purchase_request.reference, purchase_request_path(prs.purchase_request)) }
    end
    html.join("<br />")
  end
  
  def display_quotation_request_purchase_order_reference(quotation_request)
    return unless quotation_request.quotation and quotation_request.quotation.purchase_order
    link_to(quotation_request.quotation.purchase_order.reference || "Non validé", purchase_order_path(quotation_request.quotation.purchase_order))
  end
  
  def display_quotation_request_buttons(quotation_request)
    html = []
    html << display_quotation_request_show_button(quotation_request, '')
    html << display_quotation_request_confirm_button(quotation_request, '')
    html << display_quotation_request_edit_button(quotation_request, '')
    html << display_quotation_request_delete_button(quotation_request, '')
    html << display_quotation_request_cancel_button(quotation_request, '')
    html << display_quotation_request_make_copy_button(quotation_request, '')
    html << display_quotation_request_review_button(quotation_request, '')
    html << display_quotation_request_send_to_another_supplier_button(quotation_request, '')
    html.compact.join("&nbsp;")
  end
  
  def update_supplier_contacts_div(div_classname, script_to_get_supplier_id, quotation_request_id)
    #TODO find a way to add this behavior without repeating this code here because it's already present in the custom_text_field_with_auto_complete :after_update_element by default
    
    "function(input,li){
      target_id = li.down('.supplier_name_id')
      target_value = li.down('.supplier_name_value')
      if (target_id) { $('quotation_request_supplier_id').value = target_id.innerHTML }
      if (target_value) { input.setAttribute('restoreValue', target_value.innerHTML); input.value = input.getAttribute('restoreValue'); }
      #{remote_function(:update => div_classname, :url => { :action => :update_supplier_contacts }, :with => "'quotation_request_id=#{quotation_request_id}&supplier_id='+ #{script_to_get_supplier_id}")}
     }"
  end
end
