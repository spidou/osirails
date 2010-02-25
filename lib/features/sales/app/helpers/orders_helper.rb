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
  
  def generate_quote_contextual_menu_partial
    render :partial => 'quotes/contextual_menu'
  end
  
  def generate_press_proof_contextual_menu_partial
    render :partial => 'press_proofs/contextual_menu'
  end
  
  def generate_pre_invoicing_step_contextual_menu_partial
    render :partial => 'pre_invoicing_step/contextual_menu'
  end
  
  def generate_delivery_note_contextual_menu_partial
    render :partial => 'delivery_notes/contextual_menu'
  end
  
  def generate_invoicing_step_contextual_menu_partial
    render :partial => 'invoicing_step/contextual_menu'
  end
  
  def generate_invoice_contextual_menu_partial
    render :partial => 'invoices/contextual_menu'
  end
  
  def display_customer_overview
    if @order.new_record?
      html = "<h2>Informations concernant le client</h2>"
      html << "<div class='presentation_medium'>"
      html << render(:partial => 'thirds/third', :object => @order.customer, :locals => { :force_show_view => true })
      html << render(:partial => 'customers/customer_stats', :object => @order.customer)
      html << "</div>"
    end
  end
  
  def remaining_time_before_delivery(order)
    status = order.critical_status
    
    message = "Livraison prévue "
    days = (Date.today - order.previsional_delivery).abs
    date = order.previsional_delivery.humanize
    
    case status
    when Order::CRITICAL, Order::LATE
      message << "J+#{days}"
    when Order::TODAY
      message << "Jour J"
    when Order::SOON, Order::FAR
      message << "J-#{days}"
    else
      return
    end
    
    edit_order = Order.can_edit?(current_user) ? edit_order_link(order, :link_text => nil, :image_tag => image_tag("edit_16x16.png", :alt => text = "Modifier la date de livraison prévue", :title => text)) : ""
    
    content_tag( :p, content_tag(:span, message) + "<br/>le " + content_tag(:span, date) + edit_order, :class => "order_deadline #{status}" )
  end
  
end
