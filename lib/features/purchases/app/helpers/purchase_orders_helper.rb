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

end
