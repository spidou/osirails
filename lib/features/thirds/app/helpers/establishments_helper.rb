module EstablishmentsHelper
  
  def display_establishments_list(customer)
    return unless Establishment.can_list?(current_user)
    establishments = customer.activated_establishments
    html = "<div id=\"establishments\" class=\"resources\">"
    unless establishments.empty?
      html << render(:partial => 'establishments/establishment_in_one_line', :collection => establishments, :locals => { :establishments_owner => customer })
    else
      html << "<p>Aucun établissement n'a été trouvé</p>"
    end
    html << "</div>"
  end
  
  def display_establishment_add_button(customer)
    return unless Establishment.can_add?(current_user)
    
    content_tag( :p, link_to_function "Ajouter un établissement" do |page|
      page.insert_html :bottom, :establishments, :partial => 'establishments/establishment_in_one_line', :object => Establishment.new, :locals => { :establishments_owner => customer }
      last_element = page['establishments'].select('.resource').last
      last_element.visual_effect :highlight
    end )
  end
end
