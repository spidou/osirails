module OrdersHelper
  
  def order_header
    html = generate_order_order_partial
    html += generate_contextual_menu_partial
    html
  end
  
  def generate_order_order_partial
    render :partial => 'orders/order_header'
  end
  
  def generate_contextual_menu_partial
    render :partial => 'orders/contextual_menu'
  end
  
  def generate_shared_contextual_menu_partial
    render :partial => 'shared/shared_contextual_menu'
  end
  
  def generate_commercial_step_contextual_menu_partial
    render :partial => 'commercial_step/contextual_menu'
  end
  
  def generate_commercial_step_minimal_contextual_menu_partial
    render :partial => 'commercial_step/minimal_contextual_menu'
  end
  
  def generate_survey_step_contextual_menu_partial
    render :partial => 'survey_step/contextual_menu'
  end
  
  def generate_quote_step_contextual_menu_partial
    render :partial => 'quote_step/contextual_menu'
  end
  
  def generate_press_proof_step_contextual_menu_partial
    render :partial => 'press_proof_step/contextual_menu'
  end
  
  def generate_quote_contextual_menu_partial
    render :partial => 'quotes/contextual_menu'
  end
  
  def generate_press_proof_contextual_menu_partial
    render :partial => 'press_proofs/contextual_menu'
  end
  
  def generate_graphic_items_contextual_menu_partial
    render :partial => 'graphic_items/contextual_menu'
  end
  
  def generate_production_step_contextual_menu_partial
    render :partial => 'production_step/contextual_menu'
  end
  
  def generate_production_step_minimal_contextual_menu_partial
    render :partial => 'production_step/minimal_contextual_menu'
  end
  
  def generate_manufacturing_step_contextual_menu_partial
    render :partial => 'manufacturing_step/contextual_menu'
  end
  
  def generate_delivery_step_contextual_menu_partial
    render :partial => 'delivery_step/contextual_menu'
  end
  
  def generate_delivery_note_contextual_menu_partial
    render :partial => 'delivery_notes/contextual_menu'
  end
  
  def generate_invoicing_step_contextual_menu_partial
    render :partial => 'invoicing_step/contextual_menu'
  end
  
  def generate_invoicing_step_minimal_contextual_menu_partial
    render :partial => 'invoicing_step/minimal_contextual_menu'
  end
  
  def generate_invoice_step_contextual_menu_partial
    render :partial => 'invoice_step/contextual_menu'
  end
  
  def generate_invoice_contextual_menu_partial
    render :partial => 'invoices/contextual_menu'
  end
  
  def display_customer_overview
    render(:partial => 'orders/customer_overview', :locals => { :order => @order }) if @order.new_record?
  end
  
  def remaining_time_before_delivery(order)
    status = order.critical_status
    
    days = (Date.today - order.previsional_delivery).abs
    date = l(order.previsional_delivery)
    
    case status
    when Order::CRITICAL, Order::LATE
      message = "J+#{days} après livraison<br/>le #{date}"
    when Order::TODAY
      message = "Jour J<br/>Livraison prévue Aujourd'hui"
    when Order::SOON, Order::FAR
      message = "J-#{days} avant livraison<br/>le #{date}"
    else
      return
    end
    
    edit_order = edit_order_link(order, :link_text => '', :html_options => { :title => "Modifier la date prévisionnelle de livraison" })
    content_tag( :p, message + ( edit_order || "" ), :class => "order_deadline #{status}" )
  end
  
  def display_intervention_cities_for(order)
    order.ship_to_addresses.collect{ |s| s.address.city_name }.join('<br/>')
  end
  
  def display_survey_step_button(order, message = nil)
    return unless SurveyStep.can_view?(current_user)
    link_to_unless_current(message || "Voir le \"Survey\"",
                           order_commercial_step_survey_step_path(order),
                           'data-icon' => :show) {nil}
  end
  
  def display_quote_step_button(order, message = nil)
    return unless QuoteStep.can_view?(current_user)
    link_to_unless_current(message || "Voir le(s) devis du dossier",
                           order_commercial_step_quote_step_path(order),
                           'data-icon' => :index) {nil}
  end
  
  def display_press_proof_step_button(order, message = nil)
    return unless PressProofStep.can_view?(current_user)
    link_to_unless_current(message || "Voir les BAT du dossier",
                           order_commercial_step_press_proof_step_path(order),
                           'data-icon' => :index) {nil}
  end
  
  def display_manufacturing_step_button(order, message = nil)
    return unless ManufacturingStep.can_view?(current_user)
    link_to_unless_current(message || "Voir la \"Fabrication\"",
                           order_production_step_manufacturing_step_path(order),
                           'data-icon' => :show) {nil}
  end
  
  def display_delivery_step_button(order, message = nil)
    return unless DeliveryStep.can_view?(current_user)
    link_to_unless_current(message || "Voir les BL du dossier",
                           order_production_step_delivery_step_path(order),
                           'data-icon' => :index) {nil}
  end
  
  def display_invoice_step_button(order, message = nil)
    return unless InvoiceStep.can_view?(current_user)
    link_to_unless_current(message || "Voir les factures du dossier",
                           order_invoicing_step_invoice_step_path(order),
                           'data-icon' => :index) {nil}
  end
  
end
