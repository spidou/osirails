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
  
  # method that permit to add with javascript a new record of number
  def add_number_link()
    balise_img = "<img src=\"/images/add_16x16.png\" alt=\"Ajouter le numéro\" title=\"Ajouter le numéro\"/>"
    link_to_function balise_img do |page|
      page.insert_html :bottom, :numbers, :partial => "number", :object => Number.new, :locals => {:attribute => 'employee' }
    end  
  end 
  
  # method that permit to remove with javascript a new record of number
  def remove_number_link()
    balise_img = "<img src=\"/images/delete_16x16.png\" alt=\"Enlever le numéro\" title=\"Enlever le numéro\"/>"
    link_to_function( balise_img , "$(this).up('.number').remove()")  
  end 
  
  # method that permit to remove with javascript an existing number
  def remove_old_number_link()
    balise_img = "<img src=\"/images/delete_16x16.png\" alt=\"Enlever le numéro\" title=\"Enlever le numéro\"/>"
    link_to_function( balise_img , "mark_resource_for_destroy(this)") 
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
  
  def display_employee_edit_link(employee)
    html = ""
    if controller.can_edit?(current_user) and Employee.can_edit?(current_user)
       html << link_to( 'Modifier', edit_employee_path(employee))
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
      td = "<td" 
      td+= " title='" + visibles_numbers( numbers ).first.indicative.indicative + " " + visibles_numbers( numbers ).first.formatted + " (" + visibles_numbers( numbers ).first.indicative.country.name + ")'" unless visibles_numbers( numbers ).first.indicative.nil?
      td+= ">"    
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
  
  # method that permit the showing of img balise with otions passed aas arguments  
  def display_image(path,alt,title=alt)
    image_tag(path, :alt => alt, :title => title)
  end

    # This method permit to test permission for edit button
  def show_edit_button(employee,text="")
    if controller.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier")+text, edit_employee_path(employee))
    end
  end
  
  # This method permit to test permission for view button
  def show_view_button(employee,text="")
    if controller.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails")+text, employee_path(employee)) 
    end
  end
end
