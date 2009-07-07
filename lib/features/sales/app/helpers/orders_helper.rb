module OrdersHelper
  
  def order_header
    html = generate_order_order_partial
    html += generate_contextual_menu_partial
    html
  end
  
  def generate_contextual_menu_partial
    render :partial => 'orders/contextual_menu'
  end
  
  def generate_order_order_partial
    render :partial => 'orders/order_header'
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
    case order.critical_status
    when status = Order::CRITICAL
      message = "Livraison en retard de"
    when status = Order::LATE
      message = "Livraison en retard de"
    when status = Order::TODAY
      message = "Livraison prévue pour"
      time = "aujourd'hui"
    when status = Order::SOON
      message = "Livraison prévue dans"
    when status = Order::FAR
      message = "Livraison prévue dans"
    else
      return
    end
    
    time ||= distance_of_time_from_delivery(order)
    
    content_tag( :p, content_tag(:span, message) + " " + content_tag(:span, time), :class => "order_deadline #{status}" )
  end
  
  def distance_of_time_from_delivery(order)
    distance_of_time_in_words(Date.today, order.previsional_delivery.to_date)
  end
  
end
