module OrderHelper
  def generate_order_tabs(order)
    html = "<div class=\"tabs\"><ul>"
    html += "<li><a href=\"/orders/#{order.id}/\">Informations générales</a></li>"
    order.tree.each do |step|
      if step.parent.nil?
        html += "<li><a href=\"/orders/#{step.name}/\">#{step.title}</a></li>"
      end
    end
    html += "<li><a href=\"\">Historiques</a></li>"
    html += "</ul></div>"
  end
end