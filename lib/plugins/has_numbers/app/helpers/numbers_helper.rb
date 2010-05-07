module NumbersHelper

  def display_numbers(numbers_owner)
    html = "<div class='numbers'>"    
    html += render(:partial => 'numbers/number', :collection => numbers_owner.numbers , :locals => { :numbers_owner => numbers_owner})
    html += "<p>#{ add_number_link(numbers_owner) if is_form_view? }</p>"
    html += "</div>"
  end 
  
  def display_first_numbers(numbers_owner, quantity)
    more = 'Voir plus ...'
    less = 'Voir moins ...'
    
    html = "<div>"
    quantity.times do |i|
      html += display_full_phone_number(numbers_owner.numbers[i]) + "<br />"
    end
    unless numbers_owner.numbers.count < quantity
      numbers_list = numbers_owner.numbers[quantity..-1].collect {|n| display_full_phone_number(n) }.join("<br />")
      html += "<div style='display:none;'>#{ numbers_list }</div>" 
      html += link_to_function( more, "view_more_or_less(this, '#{ less }', '#{ more }');")
    end
    html += "</div>"
  end
  
  # method that permit to add with javascript a new record of number
  def add_number_link(numbers_owner)
    partial = escape_javascript( render(:partial => "numbers/number",
                                        :object => Number.new,
                                        :locals => { :numbers_owner => numbers_owner}) )
                                                  
    # a fake id is used to identify new contacts without id. look at contacts_helper.rb and search for "#FAKE_ID" to see how it is generated
    # TODO do not forget to remove "get_contact_fake_id(this)"  js method call when the trick will become useless.
    link_to_function( "Ajouter un numéro", h( "this.parentNode.insert({ before: '#{ partial }'}); get_contact_fake_id(this);"), :class => "add_number_link")
  end
  
  # method that permit to remove with javascript a new record of number
  def remove_number_link()
    link_to_function "Supprimer", "$(this).up('.number').remove()"
  end 
  
  # method that permit to remove with javascript an existing number
  def remove_old_number_link()
    link_to_function( "Supprimer" , "mark_number_for_destroy(this)") 
  end
  
  # Methode to get a number without images but with all informations
  def display_full_phone_number(number)
    return "" unless number
    html = []
    html << display_image( flag_path( number.indicative.country.code ), number.indicative.country.code, number.indicative.country.name )
	  html << display_image( number_type_path( number.number_type.name ), number.number_type.name )
	  html << strong("#{number.indicative.indicative} #{number.formatted}")
	  html.join("&nbsp;")
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
  
  def flag_path(country_code)
    "/images/flag/#{country_code}.gif"
  end
  
  def number_type_path(type)
    type = "cellphone" if type == "Mobile" or type == "Mobile Professionnel"
    type = "phone" if type == "Fixe" or type == "Fixe Professionnel"
    type = "fax" if type == "Fax" or type== "Fax Professionnel"
    "/images/"+type+"_16x16.png"
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
  
  def number_type_path(type)
    type = "cellphone" if type == "Mobile" or type == "Mobile Professionnel"
    type = "phone" if type == "Fixe" or type == "Fixe Professionnel"
    type = "fax" if type == "Fax" or type== "Fax Professionnel"
    type + "_16x16.png"
  end
  
  # method that permit the showing of img balise with otions passed as arguments  
  def display_image(path,alt,title=alt)
    image_tag(path, :alt => alt, :title => title)
  end
end
