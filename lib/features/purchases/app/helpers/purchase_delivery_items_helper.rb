module PurchaseDeliveryItemsHelper
  def display_purchase_delivery_item_total(purchase_delivery_item)
    return 0 unless purchase_delivery_item.purchase_delivery_item_total
    purchase_delivery_item.purchase_delivery_item_total.to_f.to_s(2) + "&nbsp;&euro;"
  end
  
  def display_purchase_delivery_item_buttons(purchase_delivery_item)
    html = []
    html << display_purchase_delivery_item_cancel_button(purchase_delivery_item, '') unless (params[:action] == "cancel" or params[:action] == "cancel_form")
    html << display_purchase_delivery_item_report_issue_button(purchase_delivery_item, '') unless (params[:action] == "report_form" or params[:action] == "report")
    html.compact.join("&nbsp;")
  end
  
  def display_purchase_delivery_item_cancel_button(purchase_delivery_item, message = nil)
    return unless PurchaseDeliveryItem.can_cancel?(current_user) and purchase_delivery_item.can_be_cancelled?
    text = "Annuler le contenu"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             purchase_order_purchase_delivery_purchase_delivery_item_cancel_form_path(purchase_delivery_item.purchase_order_supply.purchase_order, purchase_delivery_item.purchase_delivery, purchase_delivery_item),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_purchase_delivery_item_report_issue_button(purchase_delivery_item, message = nil)
    return unless purchase_delivery_item.can_be_reported?
    text = "Signaler un problème sur la fourniture"
    message ||= " #{text}"
    link_to( image_tag( "red_flag_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
              purchase_order_purchase_delivery_purchase_delivery_item_report_form_path(purchase_delivery_item.purchase_order_supply.purchase_order, purchase_delivery_item.purchase_delivery, purchase_delivery_item))
  end
  
  def display_purchase_delivery_item_issued_at(purchase_delivery_item)
    return "" unless purchase_delivery_item.issued_at_was
    purchase_delivery_item.issued_at_was.humanize
  end
  
  def display_purchase_delivery_item_issues_quantity(purchase_delivery_item)
    purchase_delivery_item.issues_quantity_was if purchase_delivery_item.issued_at_was
  end
  
  def display_purchase_delivery_item_must_be_reshipped(purchase_delivery_item)
    purchase_delivery_item.must_be_reshipped_was ? "Oui" : (purchase_delivery_item.issued_at_was ? "Non" : "")
  end
  
  def display_purchase_delivery_item_send_back_to_supplier(purchase_delivery_item)
    purchase_delivery_item.send_back_to_supplier_was ? "Oui" : (purchase_delivery_item.issued_at_was ? "Non": "")
  end
end
