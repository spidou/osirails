module EstablishmentsHelper
  
  # This method permit to show or hide action menu
  def show_establishment_action_menu(establishment)
    if controller.can_edit?(current_user) and Establishment.can_add?(current_user)
      html = ""
      html += "<h1><span class='gray_color'>Actions</span> <span class='blue_color'>possible</span></h1>"
      html += "<ul>"
      html +=  "<li>#{display_edit_button(establishment)} Modifier l'&eacute;tablissement</li>"
      html += "</ul>"
    end
  end
  
  def display_establishment_edit_button(establishment, customer)
    if controller.can_edit?(current_user) and Establishment.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_establishment_path(establishment)) 
    end
  end
  
  def get_address_form(owner_address)
    render :partial => 'addresses/address',  :locals => {:owner_address => owner_address, :cpt => 1}
  end
  
#  ## Display all establishments and add button (use in edit)
#  def display_establishment_and_add_establishment_button(customer, establishments, params, new_establisment_number, error)
#    establisment_controller = Menu.find_by_name('establishments')
#    html = ""
#    
#    if establisment_controller.can_list?(current_user) and Establishment.can_list?(current_user)
#      html += "<p>"
#      html = display_establishments(customer, establishments)
#      html += "</p>"
#    end
#    
#    if establisment_controller.can_add?(current_user) and Establishment.can_add?(current_user)
#      html += "<p>"
#      html += display_add_establishment_button(params, new_establisment_number, error)
#      html += "</p>"
#    end
#    
#    return html
#  end
#  
#  ## Display establishments lists
#  def display_establishments(customer, establishments)
#    establisment_controller = Menu.find_by_name('establishments') 
#    
#    html = "<h2>&Eacute;tablissements</h2>"
#    unless establishments.empty?
#      for establishment in establishments
#        html += "<p>"
#        html += establishment.name + '(' +establishment.address.city_name + ') '
#        if establisment_controller.can_view?(current_user) and Establishment.can_view?(current_user)
#          html += link_to "Plus d'infos", customer_establishment_path(customer, establishment) #, :owner_type => "Customer")
#        end
#        if establisment_controller.can_delete?(current_user) and Establishment.can_delete?(current_user)
#          html += "&nbsp;" + link_to("Supprimer", [customer,  establishment], :method => :delete, :confirm => 'Etes vous sûr ?')
#        end
#        html += "</p>"
#      end
#    else
#      html += "<p>"
#      html += "Aucun &Eacute;tablissements"
#      html += "</p>"
#    end
#    
#    return html
#  end
  def display_establishments_list
    html = "<h2>&Eacute;tablissements</h2>"
    html << "<div id=\"establishments\">"
    html << render(:partial => 'establishments/establishments_list')
    html << "</div>"
  end
  
  ## Display add establishment button
  def display_add_establishment_button(params, new_establishment_number, error)
    render :partial => 'establishments/new_establishment', :locals => {:params => params, :new_establishment_number => new_establishment_number, :error => error}
  end
  
end
