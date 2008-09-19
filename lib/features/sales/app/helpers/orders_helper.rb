module OrdersHelper
  def order_header
    render :partial => 'orders/order_header'
  end
  
  def general_information
    html = generate_order_tabs('general_information')
    html += "<div class=\"frame tabulation\">"
    html += render :partial => 'orders/steps'
    html += render :partial => 'orders/general_information'
    html += "</div>"
    html
  end
  
  def order_form
    render :partial => 'orders/form'
  end
  
  def generate_order_tabs(tab_name)
    html = "<div class=\"tabs\"><ul>"
    html += "<li "
    html += class_selected if tab_name == 'general_information'
    html +="><a href=\"/@orders/#{@order.id}/\">Informations générales</a></li>"
    @order.tree.each do |step|
      if step.parent.nil?
        html += "<li><a href=\"/@orders/#{step.name}/\">#{step.title}</a></li>"
      end
    end
    html += "<li "
    html += class_selected if tab_name == 'log'
    html +="><a onclick=\"alert('TODO');\" href=\"#\">Historiques</a></li>"
    html += "</ul></div>"
  end
  
  def class_selected
    "class=\"selected\""
  end
end