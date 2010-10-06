module EmployeesHelper
  
  ###############################################################################
  # Methods to display form parts with or without  content when raise an error ##
  ###############################################################################
  
  def display_social_security(default=nil)
    option = [{:size => 13, :maxlength => 13, :class => "disable-stylesheet-width"}, {:size => 2, :maxlength => 2, :class => "disable-stylesheet-width"}]
    social_security = default.nil? ? params[:social_security] || "" : default
    html = text_field_tag( 'social_security_number[0]', social_security.split(" ")[0], option[0]) + "\n"
    html += text_field_tag( 'social_security_number[1]', social_security.split(" ")[1], option[1])
  end
 
  #########################################################################################
  ##### Methods to show or not with permissions some stuff like buttons or link ###########
  
  # This method permit to show or hide content of secondary menu
  def actives_employees_link(view_inactives)
    return unless Employee.can_view?(current_user)
    message = "Voir tous les employés"
    message += " inactifs" if view_inactives
    link_to(image_tag("view_16x16.png", :alt => message, :title => message) + " #{message}", employees_path(:all_employees => !view_inactives))
  end
  
  #########################################################################################
  
  def display_employee_seniority(hire_date)
    return "Contrat de travail non défini" if hire_date.nil?
    day    = (Date.today - hire_date).to_i
    year   = day/365.25                # 1.year/60/60/24 == 365.25
    month  = day/30                    # 1.month/60/60/24 == 30
    result = ''
    
    if year > 1
      month  = (year - year.floor)*12
      year   = year.floor
      ytext  = year>1? 'ans' : 'an'
      result += "#{year} #{ytext} " unless year == 0
    end
    result += "et " if result != ''
    if month > 1
      month = month.floor
      result += "#{month} mois " unless month == 0
    end
    
#    day = day - year*365.25 - month*30
    
    result += "moins d'un mois" if result == ''
    result
  end
  
  # Method to verify if the params[:employee] and his attributes are null
  # TODO the name and the method (services don't use it anymore)
  #
  def is_in?(object, collection, attribute = nil, employee = nil)
    if employee.nil? and !attribute.nil? 
      return false if params[:employee].nil?
      params[:employee][attribute].nil? ? false : params[:employee][attribute].include?(object.id.to_s)  
    else
      collection=='services'? employee.services.include?(object) : employee.jobs.include?(object)
    end
  end
  
  # Method to find the service's responsibles
  def get_responsibles
    return "<strong>aucun(s)</strong>" if @employee.service.responsibles.empty?
    html = ""
    for responsible in @employee.service.responsibles
      html += ", " unless @employee.service.responsibles.first == responsible
      html += (@employee.id == responsible.id)? responsible.fullname : link_to(responsible.fullname, employee_path(responsible))
    end
    return html
  end
  
#  def contextual_search_for_employee
#    contextual_search("Employee", ["*", "user.*", "service.name", "jobs.name"])
#  end
  
  ################################
  ##  integrated search helpers ##
  ################################
  
  def query_td_content_for_fullname_in_employee_index
    link_to(@query_object.fullname, employee_path(@query_object))
  end
  
  def query_td_content_for_numbers_number_in_employee_index
    display_full_phone_number(@query_object.numbers.visibles.first) if @query_object.numbers.visibles.first
  end
  
  def query_td_content_for_actions_in_employee_index
    employee_link(@query_object, :link_text => "") + edit_employee_link(@query_object, :link_text => "")
  end
  
  def query_td_for_actions_in_employee_index(content)
    content_tag(:td, content, :class => 'actions') 
  end
  
  def query_group_td_content_in_employee(group_by)
    content_tag(:span, :class => 'not-collapsed', :onclick => "toggleGroup(this);") do   
      group_by.map {|n| "#{ translate(@query.group.at(group_by.index(n))) } #{ content_tag(:span, n, :style => 'color:#555;') }"}.join(' et ')
    end
  end
  
  def query_thead_tr_in_employee_index(content)
    query_thead_tr_with_context_menu(content, toggle_selectable_items_link(image_tag("confirm_16x16.png"), "employee"))
  end
  
  def query_tr_in_employee_index(content)
    query_tr_with_context_menu(content, @query_object, "employee_tr")
  end
  
  def translate(attr)
    tr = {'last_name' => 'de la famille', 'service.name' => 'dans le service'}
    return tr[attr]
  end
end
