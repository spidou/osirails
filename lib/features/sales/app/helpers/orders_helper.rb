module OrdersHelper
  
  def order_header
    html = generate_order_order_partial
    html += generate_order_tabulated_menu
    html += generate_contextual_menu_partial
    html
  end
  
  def generate_contextual_menu_partial
    render :partial => 'orders/contextual_menu'
  end
  
  def generate_order_tabulated_menu
    #step_name = controller.controller_name
    #step = Step.find_by_name(step_name)
    step = controller.class.step rescue nil
    menu_name = step.nil? ? controller.controller_name : step.first_parent.name
    generate_tabulated_menu(Menu.find_by_name(menu_name), Menu.activated.find_all_by_parent_id(Menu.find_by_name("orders").id))
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
  
  def order_steps
    step = controller.class.step
    step_name = step.name
    parent_step = step.first_parent
    parent_step_name = parent_step.name
    
    orders_steps = @order.send(parent_step_name).children_steps
    
    html = "<div id=\"steps\">"
    orders_steps.each do |step|
      selected = step.original_step_name == step_name ? "selected" : ""
      status = step.uncomplete? ? 'uncomplete' : step.status
      step_ring_id = step.original_step_name
      step_title = step.original_step.title
      # link = link_to(step_title, send("order_step_#{step.original_step.path}_path", @order))
      step_link = send("order_step_#{step.original_step.path}_path", @order)
      
    	html += "<div class=\"step #{selected}\" onclick=\"javascript:document.location='#{step_link}'\">"
    	html += "	<div class=\"step_status #{status}\">"
    	html += "		<div class=\"step_ring\" id=\"#{step_ring_id}\">"
    	html += "			<p>"
    	html += "				<span><strong>[#{step.original_step.title}]</strong></span>"
    	html += "			</p>"
    	html += "		</div>"
    	html += "		<div class=\"step_text\">"
    	html += "			<p>"
    	html += "       #{link_to(step_title, step_link)}"
    	html += "			</p>"
    	html += "		</div>"
    	html += "	</div>"
    	html += "</div>"
    end
    #orders_steps.each do |step|
    #   html += order_step_validation(step) if step.name == step_name
    #end
    html += "</div>"
  	html
  end
  
#  def order_step_validation(step)
#    html = "<div>"
#  	html += "	<div class=\"ring_#{step.status}\">"
#  	html += "		<div id=\"validation\">"
#  	html += "			<p>"
#  	html += "				<span><strong>[Validation]</strong></span>"
#  	html += "			</p>"
#  	html += "		</div>"
#  	html += "		<div class=\"steps_text\">"
#  	html += "			<p>"
#  	html += "				<a href=\"\">Validation</a>"
#  	html += "			</p>"
#  	html += "		</div>"
#  	html += "	</div>"
#  	html += "</div>"
#  	html
#  end
end
