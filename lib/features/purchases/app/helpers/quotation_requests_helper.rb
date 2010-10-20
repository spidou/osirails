module QuotationRequestsHelper
  def generate_quotation_request_contextual_menu_partial(quotation_request = nil)
    render :partial => 'quotation_requests/contextual_menu', :object => quotation_request
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
    return unless QuotationRequest.can_delete?(current_user) and quotation_request.can_be_deleted?
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
    link_to( image_tag( "edit_16x16.png eraser_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             :action => "review" )
  end
end
