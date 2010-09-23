module ShipToAddressesHelper
  
  def display_ship_to_addresses_list(order)
    return unless ShipToAddress.can_list?(current_user)
    ship_to_addresses = order.ship_to_addresses
    html = "<div id=\"ship_to_addresses\" class=\"resources\">"
    unless ship_to_addresses.empty?
      html << render(:partial => 'ship_to_addresses/ship_to_address', :collection => ship_to_addresses, :locals => { :establishments => order.customer.establishments })
    end
    html << "</div>"
  end
  
  def display_new_establishments_list(order)
    render_new_establishments_list(order)
  end
  
  def display_establishment_add_button(order)
    return unless Establishment.can_add?(current_user)
    content_tag( :p, link_to_function "Ajouter un établissement comme adresse de livraison" do |page|
      page.insert_html :bottom, :new_establishments, :partial => 'establishments/establishment', :object => order.customer.build_establishment, :locals => { :establishments_owner => order }
      last_element = page['new_establishments'].show.select('.resource').last
      last_element.visual_effect :highlight
    end )
  end
  
  def display_ship_to_addresses_picker(order, establishments)
    render :partial => 'ship_to_addresses/ship_to_addresses_picker', :object => order.ship_to_addresses, :locals => { :establishments => establishments.select{|e|!e.new_record?} }
  end
  
  def display_ship_to_address_edit_button
    link_to_function "Modifier", "mark_resource_for_update(this)" if is_form_view?
  end

  def display_ship_to_address_delete_button
    link_to_function "Supprimer", "mark_resource_for_destroy(this)" if is_form_view?
  end
  
  private
    def render_new_establishments_list(order)
      new_establishments = order.customer.establishments.select{ |contact| contact.new_record? }
      html =  "<div class=\"resource_group establishment_group new_records\" id=\"new_establishments\" #{"style=\"display:none\"" if new_establishments.empty?}>"
      html << "  <h1>Nouveaux établissements</h1>"
      html << render(:partial => 'establishments/establishment', :collection => new_establishments, :locals => { :establishments_owner => order })
      html << "</div>"
    end
end
