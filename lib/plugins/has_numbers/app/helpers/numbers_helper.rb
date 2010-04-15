module NumbersHelper

  def display_numbers(numbers_owner)
    html  = "<h3>Numéro(s) de téléphone(s)</h3>"
    html += "<div id='numbers'>"    
    html += render :partial => 'numbers/number', :collection => numbers_owner.numbers , :locals => { :number_owner => numbers_owner }
    html += "</div>"
    html += "<p>#{ add_number_link(numbers_owner) if is_form_view? }</p>"
  end 
  
  # method that permit to add with javascript a new record of number
  def add_number_link(number_owner)
    link_to_function "Ajouter un numéro" do |page|
      page.insert_html :bottom, :numbers, :partial => "numbers/number", :object => Number.new, :locals => { :number_owner => number_owner }
    end  
  end 
  
  # method that permit to remove with javascript a new record of number
  def remove_number_link
    link_to_function "Supprimer", "$(this).up('.number').remove()"
  end 
  
  # method that permit to remove with javascript an existing number
  def remove_old_number_link
    link_to_function( "Supprimer" , "mark_resource_for_destroy(this)") 
  end
  
  # Methode to get a number without images but with all informations
  def display_full_phone_number(number)
    return "" unless number
    html = []
    html << image_tag( number_type_path( number.number_type.name ),
                       :alt   => text = number.number_type.name,
                       :title => text ) if number.number_type
    html << image_tag( flag_path( number.indicative.country.code ),
                       :alt   => text = "#{number.indicative.country.name} (#{number.indicative.indicative})",
                       :title => text )
	  html << "#{number.formatted}"
	  html.join("&nbsp;")
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
