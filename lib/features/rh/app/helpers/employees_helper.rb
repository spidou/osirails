module EmployeesHelper
  
  ###############################################################################
  # Methods to display form parts with or without  content when raise an error ##
  ###############################################################################
  
  def display_address1(default=nil)
    if default.nil?
      text_field_tag( 'employee[address][address1]',params[:address].nil? ? nil : params[:address]['address1'] )
    else
      text_field_tag( 'employee[address][address1]', default)
    end
    
  end
  
  def display_social_security(default=nil)
    if default.nil?
      html = text_field_tag( 'social_security_number[0]', params[:social_security].nil? ? "" : params[:social_security].split(" ")[0], :size => 11, :maxlength => 13, :class => "disable-stylesheet-width") + "\n"
      html += text_field_tag( 'social_security_number[1]', params[:social_security].nil? ? "" : params[:social_security].split(" ")[1], :size => 1, :maxlength => 2, :class => "disable-stylesheet-width")
    else
      html = text_field_tag( 'social_security_number[0]', default.split(" ")[0],:size => 11, :maxlength => 13, :class => "disable-stylesheet-width") + "\n"
      html += text_field_tag( 'social_security_number[1]', default.split(" ")[1],:size => 1, :maxlength => 2, :class => "disable-stylesheet-width")
    end
  end
  
   def display_address2(default=nil)
    if default.nil?
      text_field_tag( 'employee[address][address2]', params[:address].nil? ? nil : params[:address]['address2'] )
    else
      text_field_tag( 'employee[address][address2]',default)
    end  
  end
  
  def display_bank_name(default=nil)
    if default.nil?
      text_field_tag( 'iban[bank_name]',params[:iban].nil? ? "" : params[:iban]['bank_name'] , :size => 15, :maxlength => 17, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[bank_name]',default, :size => 15, :maxlength => 17, :class => 'disable-stylesheet-width')
    end
  end
   
  def display_bank_code(default=nil)
    if default.nil?
      text_field_tag( 'iban[bank_code]',params[:iban].nil? ? "" : params[:iban]['bank_code'] , :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[bank_code]',default, :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    end
  end
  
  def display_branch_code(default=nil)
    if default.nil?
      text_field_tag( 'iban[branch_code]',params[:iban].nil? ? "" : params[:iban]['branch_code'], :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[branch_code]',default, :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    end
  end
  
  def display_account_number(default=nil)
   
    if default.nil?
      text_field_tag( 'iban[account_number]',params[:iban].nil? ? "" : params[:iban]['account_number'] , :size => 8, :maxlength => 10, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[account_number]',default, :size => 8, :maxlength => 10, :class => 'disable-stylesheet-width')
    end
  end
   
  def display_key(default=nil)
    if default.nil?
      text_field_tag( 'iban[key]',params[:iban].nil? ? "" : params[:iban]['key'] , :size => 1, :maxlength => 2, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[key]',default, :size => 1, :maxlength => 2, :class => 'disable-stylesheet-width')
    end
  end
  
  def display_account_name(default=nil)
    if default.nil?
      text_field_tag( 'iban[account_name]',params[:iban].nil? ? nil : params[:iban]['account_name'])
    else
      text_field_tag( 'iban[account_name]',default)
    end
  end
  
  
  ##################################################################
  ########## NUMBERS METHODS #######################################
  
  def display_p_balise(i,owner)
    "<p id='#{ owner }_number_" + i.to_s + "'>"
  end
  
  def display_number0(owner)
    if params[owner].nil?
      number0 = text_field_tag( owner + '[numbers][0][number]', '', :size => 7, :maxlength => 9, :class => 'disable-stylesheet-width')
    else
      number0 = text_field_tag( owner + '[numbers][0][number]',params[owner]['numbers']['0']['number'], :size => 7, :maxlength => 9, :class => 'disable-stylesheet-width')
    end  
    return number0
  end
  
  def display_check_box0(owner)
    if params[owner].nil?
      check_box0 = check_box_tag( owner + "[numbers][0][visible]", true,true) + "\n"
      check_box0 += "&nbsp;Visible par tous \n" 
    else
      check_box0 = check_box_tag( owner + "[numbers][0][visible]", true, params[owner]['numbers']['0']['visible']) + "\n"
      check_box0 += "&nbsp;Visible par tous \n" 
    end
    return check_box0
  end
  
   # Method to generate text_field for each number add
  def add_number_line(owner)
    name = "#{ owner }[numbers][#{ params[:opt] }]"
    html =  "<p id='#{ owner }_number_#{ params[:opt] }'>" 
    html +=  select(name, :indicative_id,  Indicative.find(:all).collect {|p| [ p.indicative, p.id ] }, :selected =>  8 ) + "\n"
    html += text_field_tag( name + "[number]", '', :size => 7, :maxlength => 9,:class=>"disable-stylesheet-width" ) + "\n"
    html +=  select(name, :number_type_id,  NumberType.find(:all).collect {|p| [ p.name, p.id ] }, :selected => 1 ) + "\n"
    html += check_box_tag(name + "[visible]",true,true) + "\n"
    html += "&nbsp;Visible par tous \n" 
    html += "&nbsp; \n"
    html
  end
  
  # Method to generate collection_select for each number add
  def add_collection_select(owner)
    name = "#{ owner }[numbers][#{ params[:opt] }]"
    return  collection_select( name, :number_type_id, NumberType.find(:all), :id, :name) 
  end
  
  # Method to generate add_link for each number adding a number  
  def add_link_to(owner)
    return link_to_remote( "<img src=\"/images/add_16x16.png\" alt=\"Ajouter le numéro\" title=\"Ajouter le numéro\"/>",:url=>{:controller => "employees",:action=>'add_line', :opt => params[:opt].to_i + 1 , :attribute => owner }) 
  end
  
  # Method to generate remove_link for each adding or deleting
  def remove_link_to(owner)
    params[:rem].nil? ? rem = params[:opt] : rem = params[:rem] + 1
    return link_to_remote( "<img src=\"/images/delete_16x16.png\" alt=\"Enlever le numéro\" title=\"Enlever le numéro\"/>" ,:url=>{:controller => "employees",:action=>'remove_line', :rem => rem.to_i, :attribute => owner},:href=>(url_for :action=>'remove_line'),:confirm => 'Etes vous sur?') + "</p>"
  end
  
  # Method to regenerate textfield select and collection_for each number when there is a validation error
  def save_lines(owner)
    return "" if params[owner].nil?
    html = ""
    (1..params[owner]['numbers'].size + 1).each do |f|
      unless params[owner]['numbers'][f.to_s].nil?
        name =  "#{ owner }[numbers][#{ f.to_s }]"
        html += "<p id='#{ owner }_number_#{ f.to_s }'>"
        html += select(name, :indicative_id,  Indicative.find(:all).collect {|p| [ p.indicative, p.id ] }, :selected => params[owner].nil? ? 8 : params[owner]['numbers'][ f.to_s ]['indicative_id'].to_i) + "\n"
        html += text_field_tag( name+"[number]", params[owner]['numbers'][f.to_s]['number'], :size => 7, :maxlength => 9,:class=>"disable-stylesheet-width" ) +"\n"
        html += select(name, :number_type_id,  NumberType.find(:all).collect {|p| [ p.name, p.id ] }, :selected => params[owner].nil? ? 1 : params[owner]['numbers'][ f.to_s ]['number_type_id'].to_i) + "\n"
        html += check_box_tag( name + "[visible]", true, params[owner]['numbers'][f.to_s]['visible']) + "\n"
        html += "&nbsp;Visible par tous \n" 
        html += "&nbsp; \n"
        html += link_to_remote( "<img src=\"/images/delete_16x16.png\" alt=\"Enlever le numéro\" title=\"Enlever le numéro\"/>",:url=>{:controller => "employees",:action=>'remove_line', :rem => f.to_s, :attribute => owner  },:href=>(url_for :action=>'remove_line'),:confirm => 'Etes vous sur?') + "\n"
        html += "</p>"
      end
    end  
    html
  end
  
  def deleted_numbers(numbers)
  number_id=0
    for number in numbers 
      if number[:number].blank?
         hidden_field 'deleted_numbers[' + number_id.to_s + ']',number[:id].to_s
      end
      number_id+=1
    end  
  end
  #########################################################################################
  ##### Methods to show or not with permissions some stuff like buttons or link ###########
  
  def display_premia_add_link(employee, premia_controller)
    html = ""
    if premia_controller.can_add?(current_user) and Premium.can_add?(current_user)
      html << "<p>" + link_to( 'Ajouter une prime',new_employee_premium_path(employee)) + "</p>"
    end 
    return html
  end
  
  def display_premia_view_link(employee, premia_controller)
    html = ""
    if premia_controller.can_view?(current_user) and Premium.can_list?(current_user) 
      if employee.premia.size>0 
      html << "<p>" + link_to( 'Afficher toutes les primes',employee_premia_path(employee)) + "</p>"
      end
    end
    return html
  end
  
  def display_employee_back_link(employee)
    html = ""
    if controller.can_edit?(current_user) and Employee.can_edit?(current_user)
       html << link_to( 'Modifier', edit_employee_path(employee)) + "|"
    end
    return html
  end
  
  def display_job_contract_edit_link(job_contract_controller, employee)
    html = ""
    if job_contract_controller.can_list?(current_user) and JobContract.can_edit?(current_user) 
      html << "<p>" + link_to( 'Modifier le contract de travail', edit_employee_job_contract_path(employee)) + "</p>"
    end  
    return html 
  end
  
  # This method permit to show or hide content of secondary menu
  def show_content_secondary_menu(show_all)
    if ( controller.can_view?(current_user) and Employee.can_view?(current_user) ) or ( controller.can_add?(current_user) and Employee.can_add?(current_user))
      contents = []
      contents << "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1>"
      contents << "<ul>"
      
      if controller.can_add?(current_user) and Employee.can_add?(current_user)
        contents << "<li>"+link_to("<img src='/images/add_16x16.png' alt='Ajouter' title='Ajouter' /> Ajouter un employ&eacute;", new_employee_path)+"</li>"
      end
      
      if controller.can_view?(current_user) and Employee.can_view?(current_user)
          if show_all == false
            contents << "<li>"+link_to("<img src=\"/images/view_16x16.png\" alt=\"Ajouter\" title=\"Ajouter\" />  Voir tous les employ&eacute;s", :controller => 'employees', :action => 'index', :all_employees => true)+"</li>"
          else
            contents << "<li>"+link_to("<img src=\"/images/view_16x16.png\" alt=\"Ajouter\" title=\"Ajouter\" /> Voir tous les employ&eacute;s actifs", :controller => 'employees', :action => 'index', :all_employees => false)+"</li>"
          end
      end
      
      contents << "</ul>"
    end
  end
  
  #########################################################################################
  
  # Method to verify if the params[:employee] and his attributes are null
  def is_in?(object, collection, attribute = nil, employee = nil)
    if employee.nil? and !attribute.nil? 
      return false if params[:employee].nil?
      params[:employee][attribute].nil? ? false : params[:employee][attribute].include?(object.id.to_s)  
    else
      collection=='services'? employee.services.include?(object) : employee.jobs.include?(object)
    end
  end

  
  # Method to verify if the params[:responsable] and his attributes are null
  def is_resonsable_of_this_service?(service_id,employee = nil)
    if employee.nil?
      return false if params[:responsable].nil?
      params[:responsable][service_id.to_s].nil? ? false : true
    else
      employee.responsable?(service_id).include?(employee.id)
    end
  end
  

  
  # Method to find the service's responsables
  def responsable(service_id)
    tmp = EmployeesService.find(:all,:conditions => ["service_id=? and responsable=?",service_id,1 ])
    manager = ""
    tmp.each do |t|
      e = Employee.find(t.employee_id)
      manager +=  ", " unless manager==""
      manager += @employee.id==t.employee_id ? e.fullname : link_to( e.fullname,employee_path(t.employee_id))   
    end
    return manager  
  end
  
  # Method to pluralize or not the email's <h3></h3>
  def emails_h3(employee)
    return "" if employee.email=="" and employee.society_email==""
    return "<h3>Adresse électronique </h3>" if (employee.email=="") ^ (employee.society_email=="")
    return "<h3>Adresses électroniques </h3>" if employee.email!="" and employee.society_email!=""
  end
  
  # Method that return an array of visible numbers
  def visibles_numbers(numbers)
    visibles = []
    numbers.each do |number|
      visibles << number if number.visible
    end
    visibles
  end
  
  # Method that add the title to the phone number td
  def number_td(numbers)
    unless visibles_numbers(numbers)==[]
      "<td  title='" + visibles_numbers( numbers ).first.indicative.indicative + " " + visibles_numbers( numbers ).first.formatted + " (" + visibles_numbers( numbers ).first.indicative.country.name + ")'>"
    else
      "<td>"
    end
  end
  
  # Method to pluralize or not the number's <h3></h3>
  def numbers_h3(numbers)
    unless controller.can_view?(current_user) and Employee.can_view?(current_user)
      visibles = visibles_numbers(numbers)
      return "" if visibles.size==0 
      return "<h3>Numéro de telephone</h3>" if visibles.size==1
      return "<h3>Numéros de telephone</h3>"if visibles.size>1
    else
      return "" if numbers.size==0 
      return "<h3>Numéro de telephone</h3>" if numbers.size==1
      return "<h3>Numéros de telephone</h3>"if numbers.size>1
    end
  end
  
  def flag_path(country_code)
    "/images/flag/"+country_code+".gif"
  end
  
  def number_type_path(type)
    type = "cellphone" if type == "Mobile" or type == "Mobile Professionnel"
    type = "phone" if type == "Fixe" or type == "Fixe Professionnel"
    type = "fax" if type == "Fax" or type== "Fax Professionnel"
    "/images/"+type+"_16x16.png"
  end
  
  def index_actions
    return "<th colspan=\"2\">Actions</th>" if controller.can_edit?(current_user) and Employee.can_edit?(current_user)
    return "<th>Action</th>"  if !controller.can_edit?(current_user) or !Employee.can_edit?(current_user)
  end
  

    # This method permit to test permission for edit button
  def show_edit_button(employee)
    if controller.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_employee_path(employee))
    end
  end
  
  # This method permit to test permission for view button
  def show_view_button(employee)
    if controller.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails"), employee_path(employee)) 
    end
  end
  
end
