module EstablishmentsHelper
  def get_address_form(owner_address)
    render :partial => 'addresses/address',  :locals => {:owner_address => owner_address, :cpt => 1}
  end
  
  ## Display all establishments and add button (use in edit)
  def display_establishment_and_add_establishment_button(customer, establishments, params, new_establisment_number, error)
    establisment_controller = Menu.find_by_name('establishments')
    
    if establisment_controller.can_list?(current_user) and Establishment.can_list?(current_user)
      html = display_establishments(customer, establishments)
    end
    
    if establisment_controller.can_add?(current_user) and Establishment.can_add?(current_user)
      html += display_add_establishment_button(params, new_establisment_number, error) + "<br/>"
    end
    
    return html
  end
  
  ## Display establishments lists
  def display_establishments(customer, establishments)
    establisment_controller = Menu.find_by_name('establishments') 
    
    html = "<h2>&Eacute;tablissements</h2>"
    unless establishments.empty?
      for establishment in establishments
        html += "<p>"
        html += establishment.name + '(' +establishment.address.city_name + ') '
        if establisment_controller.can_view?(current_user) and Establishment.can_view?(current_user)
          html += link_to "Plus d'infos", customer_establishment_path(customer, establishment, :owner_type => "Customer")
        end
        html += "</p>"
      end
    end
    
    return html
  end
  
  ## Display add establishment button
  def display_add_establishment_button(params, new_establishment_number, error)
    render :partial => 'establishments/new_establishment', :locals => {:params => params, :new_establishment_number => new_establishment_number, :error => error}
  end
  
end
