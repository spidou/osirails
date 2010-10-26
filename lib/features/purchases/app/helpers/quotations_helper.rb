module QuotationsHelper
  def generate_quotation_contextual_menu_partial(quotation = nil)
    render :partial => 'quotations/contextual_menu', :object => quotation
  end
  
  def display_quotation_sign_button(quotation, message = nil)
    return unless quotation.can_be_signed?
    text = "Signaler la signature du devis"
    message ||= " #{text}"
    link_to( image_tag( "TODO",
                        :alt => text,
                        :title => text ) + message,
                        quotation_sign_form_path(quotation),
                        :method => :put,
                        :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le devis et vous ne pourrez plus le modifier.")
  end
  
  def display_quotation_send_button(quotation, message = nil)
    return unless quotation.can_be_sent?
    text = "Signaler l'envoi du devis"
    message ||= " #{text}"
    link_to( image_tag( "TODO",
                        :alt => text,
                        :title => text ) + message,
                        quotation_send_form_path(quotation),
                        :method => :put)
  end
  
  def display_quotation_add_button(message = nil)
    return unless Quotation.can_add?(current_user)
    text = "Nouveau devis"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_quotation_path)
  end
  
  def display_quotation_show_button(quotation, message = nil)
    return unless Quotation.can_view?(current_user) and !quotation.new_record?
    text = "Voir ce devis"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             quotation_path(quotation) )
  end
  
  def display_quotation_edit_button(quotation, message = nil)
    return unless Quotation.can_view?(current_user) and quotation.can_be_edited?
    text = "Modifier ce devis"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_quotation_path(quotation) )
  end
  
  def display_quotation_delete_button(quotation, message = nil)
    return unless Quotation.can_delete?(current_user) and quotation.can_be_destroyed?
    text = "Supprimer ce devis"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             quotation, :method => :delete, :confirm => "Êtes vous sûr?")
  end
  
  def display_quotation_cancel_button(quotation, message = nil)
    return unless Quotation.can_cancel?(current_user) and quotation.can_be_cancelled?
    text = "Annuler ce devis"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             quotation_cancel_form_path(quotation),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_quotation_reference(quotation)
    return "" unless quotation.reference
    link_to( quotation.reference, quotation_path(quotation) )
  end
  
  def display_quotation_supplier_name(quotation)
    link_to quotation.supplier.name, supplier_path(quotation.supplier)
  end
  
  def display_quotation_employee_name(quotation)
    return "" unless quotation.employee
    link_to quotation.employee.fullname, employee_path(quotation.employee)
  end
  
  def display_quotation_current_status(quotation)
    if quotation.was_cancelled?
      "Annulée"
    elsif quotation.was_signed?
      "Signé"
    elsif quotation.was_sent?
      "Envoyé"
    elsif quotation.was_drafted?
      "Brouillon"
    end
  end
  
  def display_quotation_purchase_order_reference(quotation)
    return unless quotation and quotation.purchase_order
    link_to(quotation.purchase_order.reference || "Non validé", purchase_order_path(quotation.purchase_order))
  end
  
  def display_quotation_buttons(quotation)
    html = []
    html << display_quotation_show_button(quotation, '')
    html << display_quotation_sign_button(quotation, '')
    html << display_quotation_send_button(quotation, '')
    html << display_quotation_edit_button(quotation, '')
    html << display_quotation_delete_button(quotation, '')
    html << display_quotation_cancel_button(quotation, '')
    html.compact.join("&nbsp;")
  end
  
  def update_supplier_contacts_div(div_classname, script_to_get_supplier_id, quotation_request_id)
    #TODO find a way to add this behavior without repeating this code here because it's already present in the custom_text_field_with_auto_complete :after_update_element by default
    
#    "function(input,li){
#      target_id = li.down('.supplier_name_id')
#      target_value = li.down('.supplier_name_value')
#      if (target_id) { $('quotation_request_supplier_id').value = target_id.innerHTML }
#      if (target_value) { input.setAttribute('restoreValue', target_value.innerHTML); input.value = input.getAttribute('restoreValue'); }
#      #{remote_function(:update => div_classname, :url => { :action => :update_supplier_contacts }, :with => "'quotation_request_id=#{quotation_request_id}&supplier_id='+ #{script_to_get_supplier_id}")}
#     }"
    #TODO add an action in the quotation_controller to make this method work correctly then uncomment
  end
end
