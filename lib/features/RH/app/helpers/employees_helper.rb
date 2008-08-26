module EmployeesHelper
  
  # Methods to display form parts with or without  content when raise an error 
  ###########################################################################
  
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
  
  def display_number0
    if params[:numbers].nil?
      number0 = text_field_tag( 'numbers[0][number]', '', :size => 7, :maxlength => 9, :class => 'disable-stylesheet-width')
    else
      number0 = text_field_tag( 'numbers[0][number]',params[:numbers]['0']['number'], :size => 7, :maxlength => 9, :class => 'disable-stylesheet-width')
    end  
    number0
  end
  
  def display_bank_code(default=nil)
    if default.nil?
      text_field_tag( 'iban[bank_code]',params[:iban].nil? ? "" : params[:iban]['bank_code'] , :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[bank_code]',default, :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    end
  end
  
  def display_teller_code(default=nil)
    if default.nil?
      text_field_tag( 'iban[teller_code]',params[:iban].nil? ? "" : params[:iban]['teller_code'], :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[teller_code]',default, :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
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
  
  def display_holder_name(default=nil)
    if default.nil?
      text_field_tag( 'iban[holder_name]',params[:iban].nil? ? nil : params[:iban]['holder_name'])
    else
      text_field_tag( 'iban[holder_name]',default)
    end
  end
  
  def display_p_balise(i)
    "<p id=" + i.to_s + ">"
  end
  ############################################################################################
  
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
  
  # Method to generate text_field for each number add
  def add_number_line
    name = "numbers[" + params[:opt] + "]"
    html =  "<p id='" + params[:opt] + "'>" 
    html += collection_select( name, :indicative_id, Indicative.find(:all), :id, :indicative) + "\n"
    html += text_field_tag( name + "[number]", '', :size => 7, :maxlength => 9,:class=>"disable-stylesheet-width" ) + "\n"
    html += collection_select( name, :number_type_id, NumberType.find(:all), :id, :name)
    html
  end
  
  # Method to generate collection_select for each number add
  def add_collection_select
    name = "numbers[" + params[:opt] + "]"
    return  collection_select( name, :number_type_id, NumberType.find(:all), :id, :name) 
  end
  
  # Method to generate add_link for each number adding a number  
  def add_link_to
    return link_to_remote( 'Ajouter un numéro ',:url=>{:action=>'add_line', :opt => params[:opt].to_i + 1 },:href=>(url_for :action=>'add_line')) 
  end
  
  # Method to generate remove_link for each adding or deleting
  def remove_link_to
    params[:rem].nil? ? rem = params[:opt] : rem = params[:rem] + 1
    return link_to_remote( 'Enlever le numéro',:url=>{:action=>'remove_line', :rem => rem.to_i  },:href=>(url_for :action=>'remove_line')) + "</p>"
  end
  
  # Method to regenerate textfield select and collection_for each number when there is a validation error
  def save_lines
    return "" if params[:numbers].nil?
    html = ""
    (1..params[:numbers].size + 1).each do |f|
      unless params[:numbers][f.to_s].nil?
        name =  "numbers[" + f.to_s + "]"
        html += "<p id=" + f.to_s + ">"
        html += collection_select( name, :indicative_id, Indicative.find(:all), :id, :indicative) + "\n"
        html += text_field_tag( name+"[number]", params[:numbers][f.to_s]['number'], :size => 7, :maxlength => 9,:class=>"disable-stylesheet-width" ) +"\n"
        html += collection_select(name, :number_type_id, NumberType.find(:all), :id, :name) +"\n"
        html += link_to_remote( 'Enlever le numéro',:url=>{:action=>'remove_line', :rem => f.to_s },:href=>(url_for :action=>'remove_line'))
        html += "</p>"
      end
    end  
    html
  end
  
  # Method to find the service's responsables
  def responsable(service_id)
    tmp = EmployeesService.find(:all,:conditions => ["service_id=? and responsable=?",service_id,1 ])
    manager = ""
    tmp.each do |t|
      e = Employee.find(t.employee_id)
      manager +=  ", " unless manager==""
      manager += e.fullname
      
    end
    return manager + " )" 
  end
  
  # Method to pluralize or not the email's <h3></h3>
  def emails_h3(employee)
    return "" if employee.email=="" and employee.society_email==""
    return "<h3>Adresse électronique </h3>" if (employee.email=="") ^ (employee.society_email=="")
    return "<h3>Adresses électroniques </h3>" if employee.email!="" and employee.society_email!=""
  end
  
  def numbers_h3(employee)
    return "" if employee.numbers.size==0
    return "<h3>Numéro de telephone</h3>" if employee.numbers.size==1
    return "<h3>Numéros de telephone</h3>"if employee.numbers.size>1
  end
  
  def flag_path(country_id)
    
  end
  
end
