module OrdersHelper
  def order_header
    html = render :partial => 'orders/order_header'
    html += generate_order_tabs
    html
  end
    
  def order_form
    render :partial => 'orders/form'
  end
  
  def step_ring_class(status)
    case status
  	when 'unstarted'
  	  html = 'ring_disable'
	  when 'terminated'
	    html = 'ring_finish'
    when 'in_progress'
      html = 'ring_in_progress'
  	end
  	html
  end
  
  def step_feet_class(status)
    case status
  	when 'unstarted'
  	  html = 'feet_disable'
	  when 'terminated'
	    html = 'feet_finish'
    when 'in_progress'
      html = 'feet_in_progress'
  	end
  	html 
  end
  
  def order_steps
    orders_steps = []
    
    step = Step.find_by_name(controller.controller_name)
    parent_step = step.parent.nil? ? step.name : step.parent.name
    @order.orders_steps.each do |ot|
      next if ot.step.parent.nil?
      orders_steps << ot if ot.step.parent.name == parent_step
    end
    
    html = "<div id=\"steps\">"
    orders_steps.each do |ot|
    	html += "<div>"
    	html += "	<div class=\"#{step_ring_class(ot.status.downcase)}\">"
    	html += "		<div id=\"#{ot.step.name}\">"
    	html += "			<p>"
    	html += "				<span><strong>[#{ot.step.title}]</strong></span>"
    	html += "			</p>"
    	html += "		</div>"
    	html += "		<div class=\"steps_text\">"
    	html += "			<p>"
    	html += "				<a href=\"\">#{ot.step.title}</a>"
    	html += "			</p>"
    	html += "		</div>"
    	html += "	</div>"
    	html += "</div>"
    	html += "<div class=\"#{step_feet_class(ot.status.downcase)}\"></div>"
    end
    @order.orders_steps.each do |ot|
       html += order_step_validation(ot) if ot.step.name == controller.controller_name
    end
    html += "</div>"
  	html
  end
  
  def order_step_validation(step)
    html = "<div>"
  	html += "	<div class=\"#{step_ring_class(step.status.downcase)}\">"
  	html += "		<div id=\"validation\">"
  	html += "			<p>"
  	html += "				<span><strong>[Validation]</strong></span>"
  	html += "			</p>"
  	html += "		</div>"
  	html += "		<div class=\"steps_text\">"
  	html += "			<p>"
  	html += "				<a href=\"\">Validation</a>"
  	html += "			</p>"
  	html += "		</div>"
  	html += "	</div>"
  	html += "</div>"
  	html
  end
  
  def order_type_for_select
    hash = {}
    OrderType.find(:all).each do |ot|
      hash[ot.title] = ot.id
    end
    hash
  end
  
  def generate_order_tabs
    step = Step.find_by_name(controller.controller_name)
    tab_name = step.parent.nil? ? step.name : step.parent.name
    
    html = "<div class=\"tabs\"><ul>"
    html += "<li "
    html += class_selected if tab_name == 'informations'
    html +="><a href=\"/orders/#{@order.id}/informations/\">Informations générales</a></li>"
    @order.tree.each do |step|
      if step.parent.nil?
        html += "<li "
        html += class_selected if tab_name == step.name
        html += "><a href=\"/orders/#{@order.id}/#{step.name}/\">#{step.title}</a></li>"
      end
    end
    html += "<li "
    html += class_selected if tab_name == 'logs'
    html +="><a href=\"/orders/#{@order.id}/logs/\">Historiques</a></li>"
    html += "</ul></div>"
  end
  
  def class_selected
    "class=\"selected\""
  end
end