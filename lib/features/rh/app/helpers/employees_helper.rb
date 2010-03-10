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
  
  ##################################################################
  ########## NUMBERS METHODS #######################################
  
  # method that permit to add with javascript a new record of number
  def add_number_link(employee)
    link_to_function "Ajouter un numéro" do |page|
      page.insert_html :bottom, :numbers, :partial => "numbers/number", :object => Number.new, :locals => { :number_owner => employee }
    end  
  end 
  
  # method that permit to remove with javascript a new record of number
  def remove_number_link()
    link_to_function "Supprimer", "$(this).up('.number').remove()"
  end 
  
  # method that permit to remove with javascript an existing number
  def remove_old_number_link()
    link_to_function( "Supprimer" , "mark_resource_for_destroy(this)") 
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
  
  # Methode to get a number without images but with all informations
  def display_full_phone_number(number)
    return "" unless number
    html = []
    html << display_image( flag_path( number.indicative.country.code ), number.indicative.country.code, number.indicative.country.name )
	  html << display_image( number_type_path( number.number_type.name ), number.number_type.name )
	  html << strong("#{number.indicative.indicative} #{number.formatted}")
	  html.join("&nbsp;")
  end
  
  def display_employee_seniority(hire_date)
    return "contrat de travail non établis" if hire_date.nil?
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
  
  # Method to pluralize or not the email's <h3></h3>
  def emails_h3(employee)
    return "" if employee.email == "" and employee.society_email == ""
    return "<h3>Adresse électronique </h3>" if (employee.email == "") ^ (employee.society_email == "")
    return "<h3>Adresses électroniques </h3>" if employee.email != "" and employee.society_email != ""
  end
  
  # Method that return an array of visible numbers
  def visibles_numbers(numbers)
    numbers.visibles
  end
  
  # Method that add the title to the phone number td
  def number_td(numbers)
    unless visibles_numbers(numbers).empty? or visibles_numbers(numbers).first.indicative.nil?
      number = visibles_numbers(numbers).first
      "<td title='#{number.indicative.indicative} #{number.formatted} (#{number.indicative.country.name})'>"
    else
      "<td>"
    end
  end
  
  # Method to pluralize or not the number's <h3></h3>
  def numbers_h3(numbers)
    quantity = (Employee.can_view?(current_user) ? visibles_numbers(numbers).size : number.size)
    return "" if quantity == 0 
    return "<h3>Numéro de telephone</h3>" if quantity == 1
    return "<h3>Numéros de telephone</h3>"if quantity > 1
  end
  
  def flag_path(country_code)
    "/images/flag/"+country_code+".gif"
  end
  
  def number_type_path(type)
    type = "cellphone" if type == "Mobile" or type == "Mobile Professionnel"
    type = "phone" if type == "Fixe" or type == "Fixe Professionnel"
    type = "fax" if type == "Fax" or type== "Fax Professionnel"
    type+"_16x16.png"
  end
  
  # method that permit the showing of img balise with otions passed as arguments  
  def display_image(path,alt,title=alt)
    image_tag(path, :alt => alt, :title => title)
  end
  
  def contextual_search_for_employee
    contextual_search("Employee", ["*", "user.*", "service.name", "jobs.name"])
  end

end
