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
    render(:partial => 'orders/customer_overview', :locals => { :order => @order }) if @order.new_record?
  end
  
  def edit_order_link(order, message = nil, title = nil)
    return unless Order.can_edit?(current_user) and order # and order.can_be_edited?
    text = "Modifier le dossier"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt    => title || text,
                        :title  => title || text ) + message,
             edit_order_path(order) )
  end
  
  def remaining_time_before_delivery(order)
    status = order.critical_status
    
    days = (Date.today - order.previsional_delivery).abs
    date = order.previsional_delivery.humanize
    
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
    
    edit_order = edit_order_link(order, "", "Modifier la date prévisionnelle de livraison")
    content_tag( :p, message + ( edit_order || "" ), :class => "order_deadline #{status}" )
  end
  
end
