module EmployeesHelper
  
  ###############################################################################
  # Methods to display form parts with or without  content when raise an error ##
  ###############################################################################
  
  def display_address1(default=nil)
    if default.nil?
      text_field_tag( 'address[address1]',params[:address].nil? ? nil : params[:address]['address1'] )
    else
      text_field_tag( 'address[address1]', default)
    end
  end
  
   def display_address2(default=nil)
    if default.nil?
      text_field_tag( 'address[address2]', params[:address].nil? ? nil : params[:address]['address2'] )
    else
      text_field_tag( 'address[address2]',default)
    end  
  end
  
  def display_country(default=nil)
    if default.nil?
      text_field_tag( 'address[country_name]',params[:address].nil? ? nil : params[:address]['country_name'])
    else
      text_field_tag( 'address[country_name]',default)
    end
  end
  
  def display_city(default=nil)
    if default.nil?
      text_field_tag( 'address[city_name]',params[:address].nil? ? nil : params[:address]['city_name'])
    else
      text_field_tag( 'address[city_name]', default)    
    end
  end
  
  def display_zip_code(default=nil)
    if default.nil?
      text_field_tag( 'address[zip_code]',params[:address].nil? ? nil : params[:address]['zip_code'])
    else
      text_field_tag( 'address[zip_code]',default)  
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
  
  def display_p_balise(i)
    "<p id=" + i.to_s + ">"
  end
  ##################################################################
  ########## NUMBERS METHODS #######################################

  
  def display_number0(owner)
    if params[owner].nil?
      number0 = text_field_tag( owner + '[numbers][0][number]', '', :size => 7, :maxlength => 9, :class => 'disable-stylesheet-width')
    else
      number0 = text_field_tag( owner + '[numbers][0][number]',params[owner]['numbers']['0']['number'], :size => 7, :maxlength => 9, :class => 'disable-stylesheet-width')
    end  
    number0
  end
  
   # Method to generate text_field for each number add
  def add_number_line(owner)
    name = owner + "[numbers][" + params[:opt] + "]"
    html =  "<p id='" + params[:opt] + "'>" 
    html +=  select(name, :indicative_id,  Indicative.find(:all).collect {|p| [ p.indicative, p.id ] }, :selected =>  8 ) + "\n"
    html += text_field_tag( name + "[number]", '', :size => 7, :maxlength => 9,:class=>"disable-stylesheet-width" ) + "\n"
    html +=  select(name, :number_type_id,  NumberType.find(:all).collect {|p| [ p.name, p.id ] }, :selected => 1 ) + "\n"
    html
  end
  
  # Method to generate collection_select for each number add
  def add_collection_select(owner)
    name = owner + "[numbers][" + params[:opt] + "]"
    return  collection_select( name, :number_type_id, NumberType.find(:all), :id, :name) 
  end
  
  # Method to generate add_link for each number adding a number  
  def add_link_to(owner)
    return link_to_remote( 'Ajouter un numéro ',:url=>{:action=>'add_line', :opt => params[:opt].to_i + 1 , :attribute => owner },:href=>(url_for :action=>'add_line')) 
  end
  
  # Method to generate remove_link for each adding or deleting
  def remove_link_to(owner)
    params[:rem].nil? ? rem = params[:opt] : rem = params[:rem] + 1
    return link_to_remote( 'Enlever le numéro',:url=>{:action=>'remove_line', :rem => rem.to_i},:href=>(url_for :action=>'remove_line'),:confirm => 'Etes vous sur?') + "</p>"
  end
  
  # Method to regenerate textfield select and collection_for each number when there is a validation error
  def save_lines(owner)
    return "" if params[owner].nil?
    html = ""
    (1..params[owner]['numbers'].size + 1).each do |f|
      unless params[owner]['numbers'][f.to_s].nil?
        name =  owner + "[numbers][" + f.to_s + "]"
        html += "<p id=" + f.to_s + ">"
        html +=  select(name, :indicative_id,  Indicative.find(:all).collect {|p| [ p.indicative, p.id ] }, :selected => params[owner].nil? ? 8 : params[owner]['numbers'][ f.to_s ]['indicative_id'].to_i) + "\n"
        html += text_field_tag( name+"[number]", params[owner]['numbers'][f.to_s]['number'], :size => 7, :maxlength => 9,:class=>"disable-stylesheet-width" ) +"\n"
        html +=  select(name, :number_type_id,  NumberType.find(:all).collect {|p| [ p.name, p.id ] }, :selected => params[owner].nil? ? 1 : params[owner]['numbers'][ f.to_s ]['number_type_id'].to_i) + "\n"
        html += link_to_remote( 'Enlever le numéro',:url=>{:action=>'remove_line', :rem => f.to_s  },:href=>(url_for :action=>'remove_line'),:confirm => 'Etes vous sur?')
        html += "</p>"
      end
    end  
    html
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
    return manager + " )" 
  end
  
  # Method to pluralize or not the email's <h3></h3>
  def emails_h3(employee)
    return "" if employee.email=="" and employee.society_email==""
    return "<h3>Adresse électronique </h3>" if (employee.email=="") ^ (employee.society_email=="")
    return "<h3>Adresses électroniques </h3>" if employee.email!="" and employee.society_email!=""
  end
  
  # Method to pluralize or not the number's <h3></h3>
  def numbers_h3(employee)
    return "" if employee.numbers.size==0
    return "<h3>Numéro de telephone</h3>" if employee.numbers.size==1
    return "<h3>Numéros de telephone</h3>"if employee.numbers.size>1
  end
  
  def flag_path(country_id)
    "/images/flag/"+country_id+".gif"
  end
  
  def number_type_path(type)
    type = "cellphone" if type == "Mobile" or type == "Mobile Professionnel"
    type = "phone" if type == "Fixe" or type == "Fixe Professionnel"
    type = "fax" if type == "Fax" or type== "Fax Professionnel"
    "/images/"+type+".png"
  end
end
