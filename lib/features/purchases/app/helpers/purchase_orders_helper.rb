module PurchaseOrdersHelper

  def generate_purchase_order_contextual_menu_partial
    render :partial => 'purchase_orders/contextual_menu'
  end

  def display_purchase_order_add_button(message = nil)
      text = "Nouvel ordre d'achats"
      message ||= " #{text}"
      link_to( image_tag( "add_16x16.png",
                          :alt => text,
                          :title => text ) + message,
               new_purchase_order_path)
  end
  
  def display_purchase_order_show_button(purchase_order, message = nil)
    text = "Voir cet offre d'achats"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             purchase_order_path(purchase_order) )
  end

    def display_purchase_order_edit_button(purchase_order, message = nil)
    text = "Modifier cet ordre d'achats"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_purchase_order_path(purchase_order) )
  end

  
  def display_purchase_order_supplies_list(purchase_order)
    purchase_order_supplies = purchase_order.purchase_order_supplies
    html = "<div id=\"supplies\" class=\"resources\">"
    html << render (:partial => 'purchase_order_supplies/begin_table')
    html << render (:partial => 'purchase_order_supplies/purchase_order_supply_in_one_line', :collection => purchase_order_supplies, :locals => { :purchase_order => purchase_order })
    html << render (:partial => 'purchase_order_supplies/end_table', :locals => { :purchase_order => purchase_order })
    html << "</div>"
  end
  
  def display_PU_TTC(purchase_order_supply, supplier_supply)
    if purchase_order_supply.fob_unit_price && purchase_order_supply.taxes
      html = (purchase_order_supply.fob_unit_price.to_f * ((100 + purchase_order_supply.taxes.to_f) / 100)).to_s
    else
      html = (supplier_supply.fob_unit_price.to_f * ((100 + supplier_supply.taxes.to_f) / 100)).to_s
    end
  end
  
  def display_total(purchase_order_supply)
    html = purchase_order_supply.quantity.to_f * (purchase_order_supply.fob_unit_price.to_f * ((100 + purchase_order_supply.taxes.to_f) / 100))
  end
end
