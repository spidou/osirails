module DeparturesHelper

  def display_departures_list(customer)
    return unless Departure.can_list?(current_user)
    departures = customer.activated_departures
    html = "<div id=\"departures\" class=\"resources\">"
    unless departures.empty?
      html << render(:partial => 'departures/departure_in_one_line', :collection => departures, :locals => { :departures_owner => customer })
    else
      html << "<p>Aucun point de départ n'a été trouvé</p>"
    end
    html << "</div>"
  end
  
  def display_departure_add_button(customer)
    return unless Departure.can_add?(current_user)
    
    content_tag( :p, link_to_function "Ajouter un point de départ" do |page|
      page.insert_html :bottom, :departures, :partial => 'departures/departure_in_one_line',
                                                 :object  => Departure.new,
                                                 :locals  => { :departures_owner => customer }
      last_element = page['departures'].select('.resource').last
      last_element.visual_effect :highlight
    end )
  end
  
end
