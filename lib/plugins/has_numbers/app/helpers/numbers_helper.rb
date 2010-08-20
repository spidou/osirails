module NumbersHelper

  def display_numbers(numbers_owner, params_name = nil)
    html = "<div class='numbers'>"    
    html += render(:partial => 'numbers/number', :collection => numbers_owner.numbers , :locals => { :numbers_owner => numbers_owner, :params_name => params_name}) if numbers_owner.numbers.any?
    html += "<p>#{ add_number_link(numbers_owner) if is_form_view? }</p>"
    html += "</div>"
  end 
  
  def display_first_numbers(numbers_owner, limit)
    numbers = numbers_owner.numbers
    more = 'Voir plus ...'
    less = 'Voir moins ...'
    
    html = "<div class='formatted_numbers_list' >"
    limit.times do |i|
      html += display_full_phone_number(numbers[i]) + "<br />" if numbers[i]
    end
    
    if numbers.count > limit
      numbers_list = numbers[limit..-1].collect {|n| display_full_phone_number(n) }.join("<br />")
      html += "<div style='display:none;'>#{ numbers_list }</div>" 
      html += link_to_function( more, "toggle_more_less_button(this, '#{ less }', '#{ more }');")
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
  def remove_number_link
    link_to_function "Supprimer", "$(this).up('.number').remove()"
  end 
  
  # method that permit to remove with javascript an existing number
  def remove_old_number_link
    link_to_function( "Supprimer" , "mark_number_for_destroy(this)") 
  end
  
  # Methode to get a number without images but with all informations
  def display_full_phone_number(number)
    return "" unless number and number.id
    html = []
    html << image_tag( number_type_path( number.number_type.name ),
                       :alt   => text = number.number_type.name,
                       :title => text,
                       :class => :number_type ) if number.number_type
    html << image_tag( flag_path( number.indicative.country.code ),
                       :alt   => text = "#{number.indicative.country.name}",
                       :title => text,
                       :class => :country_flag )
    html << content_tag( :span, number.indicative.indicative, :class => :indicative )
    html << content_tag( :span, number.formatted, :class => :number )
	  
	  content_tag( :span, html.join("&nbsp;"), :class => :formatted_number )
  end
  
  def flag_path(country_code)
    "/images/flag/#{country_code}.gif"
  end
  
  def number_type_path(type)
    type = "cellphone" if type == "Mobile" or type == "Mobile Professionnel"
    type = "phone" if type == "Fixe" or type == "Fixe Professionnel"
    type = "fax" if type == "Fax" or type== "Fax Professionnel"
    type + "_16x16.png"
  end
end
