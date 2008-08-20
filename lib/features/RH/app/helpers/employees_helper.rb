module EmployeesHelper
  
  # Methods to display form parts with or without  content when raise an error 
  ###########################################################################
  
  def display_address1
    if params[:address].nil?
      address1 = text_field_tag( 'address[address1]')
    else
      address1 = text_field_tag( 'address[address1]', params[:address]['address1'])
    end
    address1
  end
  
   def display_address2
    if params[:address].nil?
      address2 = text_field_tag( 'address[address2]')
    else
      address2 = text_field_tag( 'address[address2]', params[:address]['address2'])
    end
    address2
  end
  
  def display_country
    if params[:address].nil?
      country = text_field_tag( 'address[country_name]')
    else
      country = text_field_tag( 'address[country_name]', params[:address]['country_name'])
    end
    country
  end
  
  def display_city
    if params[:address].nil?
      country = text_field_tag( 'address[city_name]')
    else
      country = text_field_tag( 'address[city_name]', params[:address]['city_name'])
    end
    country
  end
  
  def display_zip_code
    if params[:address].nil?
      zip_code = text_field_tag( 'address[zip_code]')
    else
      zip_code = text_field_tag( 'address[zip_code]', params[:address]['zip_code'])
    end
    zip_code
  end
  
  def display_number0
    if params[:numbers].nil?
      number0 = text_field_tag( 'numbers[0][number]', '', :size => 8, :maxlength => 10, :class => 'disable-stylesheet-width')
    else
      number0 = text_field_tag( 'numbers[0][number]',params[:numbers]['0']['number'], :size => 8, :maxlength => 10, :class => 'disable-stylesheet-width')
    end  
    number0
  end
  
  def display_bank_code
    if params[:iban].nil?
      text_field_tag( 'iban[bank_code]', '', :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[bank_code]',params[:iban]['bank_code'] , :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    end
  end
  
  def display_teller_code
    if params[:iban].nil?
      text_field_tag( 'iban[teller_code]', '', :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[teller_code]', params[:iban]['teller_code'], :size => 3, :maxlength => 5, :class => 'disable-stylesheet-width')
    end
  end
  
  def display_account_number
   
    if params[:iban].nil?
      text_field_tag( 'iban[account_number]', '', :size => 8, :maxlength => 10, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[account_number]',params[:iban]['account_number'] , :size => 8, :maxlength => 10, :class => 'disable-stylesheet-width')
    end
  end
   
  def display_key
    if params[:iban].nil?
      text_field_tag( 'iban[key]', '', :size => 1, :maxlength => 2, :class => 'disable-stylesheet-width')
    else
      text_field_tag( 'iban[key]', params[:iban]['key'] , :size => 1, :maxlength => 2, :class => 'disable-stylesheet-width')
    end
  end
  
  def display_holder_name
    if params[:iban].nil?
      text_field_tag( 'iban[holder_name]')
    else
      text_field_tag( 'iban[holder_name]',params[:iban]['holder_name'])
    end
  end
  
  def display_p_balise(i)
    "<p id=" + i.to_s + ">"
  end
  ############################################################################################
  
  # Method to verify if the params[:employee] and his attributes are null
  def verify_param_employee(attribute,object)
    if params[:employee].nil?
      false
    else
      if params[:employee][attribute].nil?
        false
      else
        params[:employee][attribute].include?(object.id.to_s)
      end  
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
  
end
