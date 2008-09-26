module SendedMemorandumsHelper
  
  # This method permit to view a memorandum
  def view_memorandum(memorandum)    
    view = []
    view << "<p><strong>Object : </strong>#{memorandum.subject}</p>"
    view << "<p><strong>Date : </strong>#{Memorandum.get_structured_date(memorandum)}</p>"
    view << "<p><strong>Destinataire : </strong>#{Memorandum.get_recipient(memorandum)}</p>"
    view << "<hr/>"
    view << memorandum.text
    view << "<hr/>"
    view << "<p><strong>De : </strong> #{memorandum.signature}</p>"
    view << "<p><strong>Publi&eacute; par : </strong> #{Memorandum.get_employee(memorandum)}</p>"
  end
  
  # This method permit to show or hide add button and she check if a user belong employee
  def show_add_button
    add_button = []
    unless current_user.employee_id.nil?
      if Memorandum.can_add?(current_user) and controller.can_add?(current_user)
        add_button << "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1>"
        add_button << "<ul>"
        add_button << "<li>#{link_to("<img src='/images/add_16x16.png' alt='Ajouter' title='Ajouter' /> Nouvelle note de service", new_sended_memorandum_path)}</li>"
        add_button << "</ul>"
        end
    end
    add_button
  end
  
  # This method permit to show received memorandums
  def show_received_memorandums
    if Memorandum.can_view?(current_user) and controller.can_view?(current_user)
      show_received_memorandum = []
      show_received_memorandum << "<h1><span class='gray_color'>Lien</span> <span class='blue_color'>Utile</span></h1>"
      show_received_memorandum << "<ul>"
      show_received_memorandum << "<li>#{link_to('Voir la liste des notes de service re&ccedil;u', received_memorandums_path)}</li>"
      show_received_memorandum << "</ul>"
    end
  end
  
  # This method permit to initialize signature
  def initialize_signature
    services = current_user.employee.services
    signature = []
    signature << "<input  type=\"text\" size=\"30\" name=\"memorandum[signature]\" value=\"#{services.first.name}\"/>"
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
    memorandum_service
  end
  
  def recursive_mode(ancestor, memorandum)
    memorandum_service = MemorandumsService.find_by_service_id_and_memorandum_id(ancestor.id, memorandum.id)
    if memorandum_service.nil?
      return true
    else
      return ( memorandum_service.recursive ? false : true )
    end
  end

  # This method permit to disable option in select  
  def disabled(service, memorandum)
    memorandum_service = MemorandumsService.find_by_service_id_and_memorandum_id(service.id, memorandum.id)
    if memorandum_service.nil?
      service.ancestors.each do |ancestor|
        return recursive_mode(ancestor, memorandum)
      end
    else
      return false
    end
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
  def show_memorandum(memorandums)
    sended_memorandums = []
    sended_memorandums << "<table>"
    sended_memorandums << "<tr>"
    sended_memorandums << "<th>Titre de la note de service</th>"
    sended_memorandums << "<th>Date de publication</th>"
    sended_memorandums << "<th colspan='2'>Action</th>"
    sended_memorandums << "</tr>"
    
    memorandums.each do |memorandum|
      
      published = ( memorandum.published_at.nil? ? "Cette note de service n'est pas publi&eacute;" : "#{Memorandum.get_structured_date(memorandum)}")
      show_button = link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails"), sended_memorandum_path(memorandum)) if Memorandum.can_view?(current_user)
      edit_button = show_edit_button(memorandum)
      period_memorandum = Memorandum.color_memorandums(memorandum)
      
      sended_memorandums << "<tr title='#{memorandum.subject}' class='#{period_memorandum}'>"
      sended_memorandums << "<td>#{memorandum.title}</td>"
      sended_memorandums << "<td>#{published}</td>"
      sended_memorandums << "<td style='width: 50px;'>#{show_button}</td>"
      sended_memorandums << "<td style='width: 50px;'>#{edit_button}</td>"
    end
    sended_memorandums << "</table>"
  end
  
  # This method permit to show or hide edit buttton
  def show_edit_button(memorandum)
    if memorandum.published_at.nil?
      if Memorandum.can_edit?(current_user) and controller.can_edit?(current_user)
        return link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_sended_memorandum_path(memorandum))
      end
    else 
      return "<img src='/images/tick_16x16.png' alt='Publier' title='Publier' />"
    end
  end
  
end