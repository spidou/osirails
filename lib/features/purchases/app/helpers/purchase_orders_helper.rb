module PurchaseOrdersHelper

  def generate_purchase_order_contextual_menu_partial(purchase_order = nil)
    render :partial => 'purchase_orders/contextual_menu', :object => purchase_order
  end
  
  def display_purchase_order_confirm_button(purchase_order, message = nil)
    return unless purchase_order.can_be_confirmed?
    text = "Confirmer l'ordre d'achats"
    message ||= " #{text}"
    link_to( image_tag( "tick_16x16.png",
                        :alt => text,
                        :title => text ) + message,
                         purchase_order_confirm_path(purchase_order),
                        :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour l'ordre d'achat et vous ne pourrez plus le modifier.", :method => :put)
  end

  def display_purchase_order_add_button(message = nil)
    return unless PurchaseOrder.can_add?(current_user)
    text = "Nouvel ordre d'achats"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_purchase_order_path(:choice => true))
  end
  
  def display_purchase_order_show_button(purchase_order, message = nil)
    return unless PurchaseOrder.can_view?(current_user) and !purchase_order.new_record?
    text = "Voir cet ordre d'achats"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             purchase_order_path(purchase_order) )
  end

  def display_purchase_order_edit_button(purchase_order, message = nil)
    return unless PurchaseOrder.can_view?(current_user) and purchase_order.can_be_edited?
    text = "Modifier cet ordre d'achats"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_purchase_order_path(purchase_order) )
  end
  
  def display_purchase_order_delete_button(purchase_order, message = nil)
    return unless PurchaseOrder.can_delete?(current_user) and purchase_order.can_be_deleted?
    text = "Supprimer cet ordre d'achats"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             purchase_order, :method => :delete, :confirm => "Êtes vous sûr?")
  end

  def display_purchase_order_cancel_button(purchase_order, message = nil)
    return unless PurchaseOrder.can_cancel?(current_user) and purchase_order.can_be_cancelled?
    text = "Annuler cet ordre d'achats"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             purchase_order_cancel_form_path(purchase_order),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_purchase_order_supplies_list(purchase_order)
    purchase_order_supplies = purchase_order.purchase_order_supplies
    html = "<div id=\"supplies\" class=\"resources\">"
    html << render(:partial => 'purchase_order_supplies/begin_table')
    html << render(:partial => 'purchase_order_supplies/purchase_order_supply_in_one_line', :collection => purchase_order_supplies, :locals => { :purchase_order => purchase_order })
    html << render(:partial => 'purchase_order_supplies/end_table', :locals => { :purchase_order => purchase_order })
    html << "</div>"
  end
  
  def display_longest_lead_time_for_supplier(supplier)
    merged_purchase_request_supplies = supplier.merge_purchase_request_supplies
    longest_lead_time = 0
    for merged_purchase_request_supply in merged_purchase_request_supplies
      if merged_purchase_request_supply.supply.supplier_supplies.first(:conditions => ['supplier_id = ?', supplier]).lead_time
        if( merged_purchase_request_supply.supply.supplier_supplies.first(:conditions => ['supplier_id = ?', supplier]).lead_time > longest_lead_time )
          longest_lead_time = merged_purchase_request_supply.supply.supplier_supplies.first(:conditions => ['supplier_id = ?', supplier]).lead_time || 0
        end
      end
    end
    "#{longest_lead_time}&nbsp;jour(s)</p>"
  end
  
  def display_purchase_request_supplies_total_for_supplier(supplier)
    merged_purchase_request_supplies = supplier.merge_purchase_request_supplies
    totals_sum = 0
    for merged_purchase_request_supply in merged_purchase_request_supplies
      merged_purchase_request_supply_supplier = merged_purchase_request_supply.supply.supplier_supplies.first( :conditions => ['supplier_id = ?', supplier])
      totals_sum += (merged_purchase_request_supply_supplier.fob_unit_price * ((100 + merged_purchase_request_supply_supplier.taxes ) / 100)) * merged_purchase_request_supply.expected_quantity
    end
    "#{totals_sum.to_f.to_s(2)}&nbsp;&euro;"
  end
  
  def display_choose_supplier_button(supplier)
    link_to(image_tag("next_24x24.png", :alt => "Choisir" + supplier.name), new_purchase_order_path(:supplier_id => supplier, :from_purchase_request => 1))
  end
  
  def display_purchase_order_reference(purchase_order)
    return "" unless purchase_order.reference
    purchase_order.reference
  end
  
  def display_purchase_order_current_status(purchase_order)
    case purchase_order.status
      when PurchaseOrder::STATUS_DRAFT
        "Brouillon"
      when PurchaseOrder::STATUS_CONFIRMED
        "Confirmé"
      when PurchaseOrder::STATUS_PROCESSING
        "En traitement"
      when PurchaseOrder::STATUS_COMPLETED
        "Complété"
      when PurchaseOrder::STATUS_CANCELLED
        "Annulé"
    end
  end
  
  def display_purchase_order_current_status_date(purchase_order)
    case purchase_order.status
      when PurchaseOrder::STATUS_DRAFT
        purchase_order.created_at ? purchase_order.created_at.humanize : " date de création"
      when PurchaseOrder::STATUS_CONFIRMED
        purchase_order.confirmed_at ? purchase_order.confirmed_at.humanize : " date de validation"
      when PurchaseOrder::STATUS_PROCESSING
        purchase_order.processing_since ? purchase_order.processing_since.humanize : " date de début de traitement"
      when PurchaseOrder::STATUS_COMPLETED
        purchase_order.completed_at ? purchase_order.completed_at.humanize : " date de fin de traitement"
      when PurchaseOrder::STATUS_CANCELLED
        purchase_order.cancelled_at ? purchase_order.cancelled_at.humanize : " date d'annulation"
    end
  end
  
  def display_associated_purchase_requests(purchase_order)
    html = []
    associated_purchase_requests = purchase_order.get_associated_purchase_requests
    return "" if associated_purchase_requests.empty?
    for purchase_request in associated_purchase_requests
      html << link_to(purchase_request.reference, purchase_request_path(purchase_request))
    end
    html.compact.join("<br />")
  end
  
  def display_purchase_order_total_price(purchase_order, cancelled = false)
    purchase_order.total_price(cancelled).to_f.to_s(2) + "&nbsp;€"
  end
  
  def display_purchase_order_creator(purchase_order)
    return "" unless purchase_order.user_id
    purchase_order.user.employee_name
  end
  
  def display_purchase_order_paid(purchase_order, display_pictures = false)
    if display_pictures
      purchase_order.paid ? "oui" : "non" 
    else
      purchase_order.paid ? "Payé" : "Non payé"
    end
  end
  
  def display_purchase_order_lead_time(purchase_order)
    return "Immédiat" if purchase_order.lead_time == 0
    purchase_order.lead_time.to_s + "&nbsp;jour(s)"
  end
  
  def display_purchase_order_buttons(purchase_order)
    html = []
    html << display_purchase_order_confirm_button(purchase_order, '')
    html << display_purchase_order_show_button(purchase_order, '')
    html << display_purchase_order_edit_button(purchase_order, '')
    html << display_purchase_order_delete_button(purchase_order, '')
    html << display_purchase_order_cancel_button(purchase_order, '')
    html.compact.join("&nbsp;")
  end
  
  def display_all_total_price_for_purchase_order_form(purchase_order)
    result = 0;
    for purchase_order_supply in purchase_order.purchase_order_supplies
      result += purchase_order_supply.quantity.to_f * (purchase_order_supply.fob_unit_price.to_f * ((100 + purchase_order_supply.taxes.to_f) / 100))
    end
    result.to_f.to_s(2)
  end
  
end
