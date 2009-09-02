module ToolsHelper

  def link_to_service(service)
    return "-" if service.nil?
    service_link(service, :link_text => service.name, :image_tag => nil) || service.name
  end
  
  def link_to_employee(employee)
    return "-" if employee.nil?
    employee_link(employee, :link_text => employee.fullname, :image_tag => nil) || employee.fullname
  end
  
  def link_to_job(job)
    return "-" if job.nil?
    job_link(job, :link_text => job.name, :image_tag => nil) || job.name
  end
        
  def link_to_supplier(supplier)
    return "-" if supplier.nil?
    supplier_link(supplier, :link_text => supplier.name, :image_tag => nil) || supplier.name
  end

  def links_to_actions(tool)
    html = send("#{tool.class.to_s.tableize.singularize}_link", tool, :link_text => nil)
    html += send("edit_#{tool.class.to_s.tableize.singularize}_link", tool, :link_text => nil)
    html += send("delete_#{tool.class.to_s.tableize.singularize}_link", tool, :link_text => nil)
    html
  end
  
  def links_for_tool_event(tool, event)
    tool_class = tool.class.to_s.tableize.singularize
    html = send("#{tool_class}_tool_event_link", tool, event, :link_text => nil)
    html += send("edit_#{tool_class}_tool_event_link", tool, event, :link_text => nil)
    html += send("delete_#{tool_class}_tool_event_link", tool, event, :link_text => nil)
    html
  end
  
  def get_status_image(status)
    color = ['green', 'orange', 'red']
    message = ToolEvent::STATUS_TEXT[status.to_i]
    image_tag("#{color[status.to_i]}_flag_16x16.png", :title => message, :alt => message)
  end
  
  def get_status_text(status)
    ToolEvent::STATUS_TEXT[status.to_i]
  end
  
  def get_event_type_text(event_type)
    ToolEvent::TYPE_TEXT[event_type.to_i]
  end
  
  def display_events(header, events, tool, link = nil)
    return '' if events.empty?
    html = "#{header}"
    html += "<div class='presentation_small events'>"
    html += render :partial => 'tool_events/tool_event_minimal', :collection => events , :locals => {:tool => tool}
    html += "<p>#{link}</p>" unless link.nil?
    html += "</div>"
    html
  end
  
  def get_internal_actor(event)
    return '-' if event.internal_actor.nil?
    link = employee_link(event.internal_actor, :image_tag => nil, :link_text => event.internal_actor.fullname)
    link || event.internal_actor.fullname 
  end
  
  def get_end_date(event)
    return event.end_date.strftime('%A %d %B %Y') unless event.end_date.nil?
  end
  
  def effectives_image(event, is_effective)
    if is_effective
      if event.event_type_name == 'intervention'
        is_current_event = (event.start_date..event.end_date).include?(Date.today)
      else
        is_current_event = event.start_date == Date.today
      end      
      if is_current_event
        image = 'warning'
        message = 'évènement en cours'
      else
        image = 'tick2'
        message = 'évènement passé'
      end
    else
      image = 'clock'
      message = 'évènement future'
    end
    image_tag("#{image}_16x16.png", :alt => message, :title => message)
  end
  
end 
