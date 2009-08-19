module EstablishmentsHelper
  
  def display_establishments_list(customer)
    return unless Establishment.can_list?(current_user)
    establishments = customer.activated_establishments
    html = "<h2>&Eacute;tablissements</h2>"
    html << "<div id=\"establishments\">"
    unless establishments.empty?
      html << render(:partial => 'establishments/establishment_in_one_line', :collection => establishments, :locals => { :establishment_owner => customer })
    else
      html << "<p>Aucun établissement n'a été trouvé</p>"
    end
    html << "</div>"
  end
  
  def display_establishment_add_button(customer)
    return unless Establishment.can_add?(current_user)
    link_to_function "Ajouter un établissement" do |page|
      page.insert_html :bottom, :establishments, :partial => 'establishments/establishment_form', :object => Establishment.new, :locals => { :establishment_owner => customer }
    end
  end
  
#  ## Display add establishment button
#  def display_add_establishment_button(params, new_establishment_number, error)
#    render :partial => 'establishments/new_establishment', :locals => {:params => params, :new_establishment_number => new_establishment_number, :error => error}
#  end
  
end
