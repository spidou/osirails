module OrdersHelper
  
  def order_header
    html = generate_order_order_partial
    html += generate_order_tabs
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
  
  def step_ring_class(status)
    "ring_#{status}"
  end
  
  def order_steps
    order_steps_for('step_' + controller.controller_name)
  end
  
  def order_steps_for(step_name)
    step = Step.find_by_name(step_name)
    Step.cant_find if step.nil?
    step = step.first_parent
    
    orders_steps = @order.send(step.name).children
    
    html = "<div id=\"steps\">"
    orders_steps.each do |ot|
    	html += "<div #{class_selected if ot.name == step_name}>"
    	html += "	<div class=\"#{step_ring_class(ot.uncomplete? ? 'uncomplete' : ot.status)}\">"
    	html += "		<div id=\"#{ot.name[5..-1]}\">"
    	html += "			<p>"
    	html += "				<span><strong>[#{ot.step.title}]</strong></span>"
    	html += "			</p>"
    	html += "		</div>"
    	html += "		<div class=\"steps_text\">"
    	html += "			<p>"
    	html += "				<a href=\"#{order_path(@order)}/#{ot.name[5..-1]}\">#{ot.step.title}</a>"
    	html += "			</p>"
    	html += "		</div>"
    	html += "	</div>"
    	html += "</div>"
    	# html += "<div class=\"disable\"></div>"
    end
    #orders_steps.each do |ot|
    #   html += order_step_validation(ot) if ot.name == step_name
    #end
    html += "</div>"
  	html
  end
  
  def order_step_validation(step)
    html = "<div>"
  	html += "	<div class=\"#{step_ring_class(step.status)}\">"
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
  
  def generate_order_tabs
    generate_order_tabs_for(controller.controller_name)
  end
  
  def generate_order_tabs_for(s)
    step = Step.find_by_name('step_' + s)
    tab_name = step.nil? ? s : step.first_parent.name
    
    html = "<div class=\"tabs\"><ul>"
    html += "<li "
    html += class_selected if tab_name == 'informations'
    html +="><a href=\"/orders/#{@order.id}/informations/\">Informations générales</a></li>"
    @order.steps.each do |step|
      next if step.parent
      html += "<li "
      html += class_selected if tab_name == step.name
      html += link_to step.title, "#{order_path(@order)}/#{step.children.first.name[5..-1] unless step.children.empty?}"
      # html += "><a href=\"/orders/#{@order.id}/#{step.name}/\">#{step.title}</a></li>"
    end
    html += "<li "
    html += class_selected if tab_name == 'logs'
    html +="><a href=\"/orders/#{@order.id}/logs/\">Historiques</a></li>"
    html += "</ul></div>"
  end
  
  def class_selected
    "class=\"selected\""
  end
  
  def class_for_clock_progress(step)
    if params[:for] == 'step'
      return " #{step.name}" if step.in_progress? or step.terminated?
    else
      return ' terminated' if step.terminated?
    end
  end
end
