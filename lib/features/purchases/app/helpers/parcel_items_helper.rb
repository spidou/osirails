module ParcelItemsHelper
  def display_parcel_item_total(parcel_item)
    return 0 unless parcel_item.get_parcel_item_total
    parcel_item.get_parcel_item_total.to_f.to_s(2) + "&nbsp;&euro;"
  end
  
  def display_parcel_item_buttons(parcel_item)
    html = []
    html << display_supply_show_button(parcel_item.purchase_order_supply.supply, '')
    html << display_parcel_item_cancel_button(parcel_item, '')
    html << display_parcel_item_report_issue_button(parcel_item, '')
    html.compact.join("&nbsp;")
  end
  
  def display_parcel_item_cancel_button(parcel_item, message = nil)
    return unless ParcelItem.can_cancel?(current_user) and parcel_item.can_be_cancelled?
    text = "Annuler le contenu"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             parcel_item_cancel_form_path(parcel_item),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_parcel_item_report_issue_button(parcel_item, message = nil)
    return unless parcel_item.can_be_reported?
    text = "Signaler un problème sur le contenu"
    message ||= " #{text}"
    link_to( image_tag( "red_flag_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
              parcel_item_report_form_path(parcel_item))
  end
end
