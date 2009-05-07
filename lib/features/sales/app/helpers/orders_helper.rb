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
      html << render(:partial => 'thirds/third', :object => @order.customer)
      html << render(:partial => 'customers/customer_stats', :object => @order.customer)
      html << "</div>"
    end
  end
  
  def remaining_time_before_delivery(order)
    return "" unless order.previsional_delivery
    
    delay = (Date.today - order.previsional_delivery.to_date).to_i
    if delay < -7
      status = "good"
    elsif delay < 0
      status = "medium"
    elsif delay >= 0
      status = "late"
    end
    
    if delay < 0
      message = "Livraison prévue dans"
      time = distance_of_time_from_delivery(order)
    elsif delay == 0
      message = "Livraison prévue pour"
      time = "aujourd'hui"
    else
      message = "Livraison en retard de"
      time = distance_of_time_from_delivery(order)
    end
    
    html = "<p class=\"order_deadline #{status}\">"
    html << content_tag(:span, message) + " "
    html << content_tag(:span, time)
    html << "</p>"
  end
  
  def distance_of_time_from_delivery(order)
    distance_of_time_in_words(Date.today, order.previsional_delivery.to_date)
  end
  
end
