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
    link_to(message, employees_path(:all_employees => !view_inactives), 'data-icon' => :index)
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
  
end
