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
  
end
