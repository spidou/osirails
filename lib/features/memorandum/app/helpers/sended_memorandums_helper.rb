module SendedMemorandumsHelper

  # This method permit to structured date
  def get_structured_date(memorandum)
    if memorandum.published_at.nil?
      memorandum.updated_at.strftime('%d %B %Y')
    else
      memorandum.published_at.strftime('%d %B %Y')
    end
  end
  
  # This method permit to get employee information
  def get_employee(memorandum)
    user = User.find(memorandum.user_id)
    employee = "#{user.employee.first_name} #{user.employee.last_name}"
  end
  
  # This method permit to get recpient
  def get_recipient(memorandum)
    services = ""
    memorandums_services_size = memorandum.memorandums_services.size
    memorandum.memorandums_services.reverse.each do |memorandum_service|
      service = Service.find(memorandum_service.service_id)
      unless memorandum.memorandums_services.first == memorandum_service
        services += "#{service.name}, "
      else
        services += "#{service.name}."
      end      
    end
    services
  end

  # This method permit to show or hide add button and she check if a user belong employee
  def show_add_button
  add_button = []
    unless current_user.employee_id.nil?
      add_button << "<h1><span class='gray_color'>Action</span></h1>"
      add_button << "<ul>"
      add_button << "<li>#{link_to('Nouvelle note de service', new_sended_memorandum_path)}</li>"
      add_button << "</ul>"
    end
    add_button
  end

  # This method permit to initialize signature
  def initialize_signature
   signature = []
   employee_id = current_user.employee_id
   service_id = EmployeesService.find_by_employee_id(employee_id)
   service = Service.find(service_id)
   signature << "<input  type=\"text\" size=\"30\" name=\"memorandum[signature]\" value=\"#{service.name}\"/>"
  end

  # This method permit to have a services on <ul> type.
  def show_structured_services(memorandum = "none", action = "new")
    services = Service.find_all_by_service_parent_id
    list = []
    list << "<p><label>Liste des services : </label> <select onchange='addServiceCell(this)'>"
    list = get_children(memorandum, services,list,action)
    list << "</select></p>"
    list 
  end
  
  # This method permit to make a tree for services
  def get_children(memorandum, services,list,action,value = 0)
    ancestors_name = []
    services.each do |service|
    disabled = ( disabled(service, memorandum) ? "" : "disabled=''") if action == "edit"
    
    service.ancestors.each do |ancestor|
      ancestors_name << "parent_service_#{ancestor.id} " unless ancestors_name.include?("parent_service_#{ancestor.id} ")
    end
      list << "<option value='-1' selected='selected'>-- Selectionner un service --</option>" if value == 0 
      list << "<option value='0' title='Tous les services' id='service_option_0' class='parent_service_0'>Tous les services</option>" if value == 0 and action == "new"
      list << "<option value='0' title='Tous les services' id='service_option_0' class='parent_service_0' #{disabled}>Tous les services</option>" if value == 0 and action == "edit"
      list << "<option value='#{service.id}' title='#{service.name}' id='service_option_#{service.id}' class='#{ancestors_name}parent_service_0' #{disabled} >#{service.name}</option>" if action == "edit"
      list << "<option value='#{service.id}' title='#{service.name}' id='service_option_#{service.id}' class='#{ancestors_name}parent_service_0' >#{service.name}</option>" if action == "new"
      if service.children.size > 0
        value += 1
        get_children(memorandum, service.children,list,action,value)
      end
    end
    list
  end
  
  # This method permit to check if a select option must be disabled
  def disabled_mode(service, memorandum)
    memorandum_service = MemorandumsService.find_by_service_id_and_memorandum_id(service.id, memorandum.id)
    memorandum_service.nil?
  end
  
  def recursiveMode(ancestor, memorandum)
    memorandum_service = MemorandumsService.find_by_service_id_and_memorandum_id(ancestor.id, memorandum.id)
    unless memorandum_service.nil?
      !memorandum_service.recursive
    end
  end
  
  def disabled(service, memorandum)
    if service.ancestors.size == 0
      disabled_service = disabled_mode(service, memorandum)
    else
      service.ancestors.each do |ancestor|
        disabled_service = recursiveMode(ancestor, memorandum)
      end
    end
    disabled_service
  end
  
  # This method permit to show current services associeted with a memorandum
  def show_services(memorandum)
    services_list = []
    memorandums_services = MemorandumsService.find_all_by_memorandum_id(memorandum.id)
    memorandums_services.each do |memorandum_service|
      service = Service.find(memorandum_service.service_id)
      recursive = ( memorandum_service.recursive ? "recursiveModeOff(#{service.id})" : "recursiveModeOn(#{service.id})" )
      checked = (memorandum_service.recursive ? "checked='checked'" : "")
      services_list << "<tr class='services_rows service_#{service.id}'>"
      services_list << "<td>#{service.name}</td>"
      services_list << "<td>"
      services_list << "<input type='checkbox' value='#{service.id}' name='memorandums_services[service_id][]' style='display: none' checked='checked'/>"
      services_list << "<input type='checkbox' value='#{service.id}' name='memorandums_services[recursive][]' onclick='#{recursive}' #{checked} />"
      services_list << "</td>"
      services_list << "<td><img onclick='removeServiceCell(this.ancestors()[1])' src='/images/reduce_button_16x16.png' alt='Enlever' title='Enlever'/></td>"
      services_list << "</tr>"
    end
    services_list
  end
  
  # This method permit to show sended memorandum
  def show_sended_memorandum
    memorandums = Memorandum.find_all_by_user_id(current_user.id)
    sended_memorandums = []
    sended_memorandums << "<table>"
    sended_memorandums << "<tr>"
    sended_memorandums << "<th>Titre de la note de service</th>"
    sended_memorandums << "<th>Date de publication</th>"
    sended_memorandums << "<th colspan='3'>Action</th>"
    sended_memorandums << "</tr>"
    
    memorandums.each do |memorandum|
    
    published = ( memorandum.published_at.nil? ? "Cette note de service n'est pas publi&eacute;" : "#{get_structured_date(memorandum)}")
    show_button = link_to("Voir", sended_memorandum_path(memorandum))
    edit_button = ( memorandum.published_at.nil? ? link_to("Modifier", edit_sended_memorandum_path(memorandum)) : "" )
    publish_button = ( memorandum.published_at.nil? ? link_to("Publier", {:method => :put, :confirm => "Attention, une fois clôtur&eacute;, vous ne pourrez plus modifier l'inventaire"}) : "" )
    
    sended_memorandums << "<tr title='#{memorandum.subject}'>"
    sended_memorandums << "<td>#{memorandum.title}</td>"
    sended_memorandums << "<td>#{published}</td>"
    sended_memorandums << "<td style='width: 50px;'>#{show_button}</td>"
    sended_memorandums << "<td style='width: 50px;'>#{edit_button}</td>"
    sended_memorandums << "<td style='width: 50px;'>#{publish_button}</td>"
    end
  sended_memorandums << "</table>"
  end

end
