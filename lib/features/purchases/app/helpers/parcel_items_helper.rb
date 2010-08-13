module ParcelItemsHelper
  def display_parcel_item_total(parcel_item)
    return 0 unless parcel_item.parcel_item_total
    parcel_item.parcel_item_total.to_f.to_s(2) + "&nbsp;&euro;"
  end
  
  def display_parcel_item_buttons(parcel_item)
    html = []
    html << display_parcel_item_cancel_button(parcel_item, '') unless (params[:action] == "cancel" or params[:action] == "cancel_form")
    html << display_parcel_item_report_issue_button(parcel_item, '') unless (params[:action] == "report_form" or params[:action] == "report")
    html.compact.join("&nbsp;")
  end
  
  def display_parcel_item_cancel_button(parcel_item, message = nil)
    return unless ParcelItem.can_cancel?(current_user) and parcel_item.can_be_cancelled?
    text = "Annuler le contenu"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             purchase_order_parcel_parcel_item_cancel_form_path(parcel_item.purchase_order_supply.purchase_order, parcel_item.parcel, parcel_item),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_parcel_item_report_issue_button(parcel_item, message = nil)
    return unless parcel_item.can_be_reported?
    text = "Signaler un problème sur la fourniture"
    message ||= " #{text}"
    link_to( image_tag( "red_flag_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
              purchase_order_parcel_parcel_item_report_form_path(parcel_item.purchase_order_supply.purchase_order, parcel_item.parcel, parcel_item))
  end
  
  def display_parcel_item_issued_at(parcel_item)
    return "" unless parcel_item.issued_at_was
    parcel_item.issued_at_was.humanize
  end
  
  def display_parcel_item_issues_quantity(parcel_item)
    parcel_item.issues_quantity_was if parcel_item.issued_at_was
  end
  
  def display_parcel_item_must_be_reshipped(parcel_item)
    parcel_item.must_be_reshipped_was ? "Oui" : (parcel_item.issued_at_was ? "Non" : "")
  end
  
  def display_parcel_item_send_back_to_supplier(parcel_item)
    parcel_item.send_back_to_supplier_was ? "Oui" : (parcel_item.issued_at_was ? "Non": "")
  end
end
