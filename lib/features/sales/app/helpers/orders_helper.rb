module OrdersHelper
  def order_header
    html = render :partial => 'orders/order_header'
    html += generate_order_tabs
    html
  end
    
  def order_form
    render :partial => 'orders/form'
  end
  
  def generate_order_tabs
    tab_name = controller.controller_name
    html = "<div class=\"tabs\"><ul>"
    html += "<li "
    html += class_selected if tab_name == 'informations'
    html +="><a href=\"/orders/#{@order.id}/informations/show\">Informations générales</a></li>"
    @order.tree.each do |step|
      if step.parent.nil?
        html += "<li "
        html += class_selected if tab_name == step.name
        html += "><a href=\"/orders/#{@order.id}/#{step.name}/show\">#{step.title}</a></li>"
      end
    end
    html += "<li "
    html += class_selected if tab_name == 'logs'
    html +="><a href=\"/orders/#{@order.id}/logs/show\">Historiques</a></li>"
    html += "</ul></div>"
  end
  
  def class_selected
    "class=\"selected\""
  end
end