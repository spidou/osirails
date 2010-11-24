module EstablishmentsHelper
  
  def display_establishments_list(owner)
    return unless Establishment.can_list?(current_user)
    establishments = owner.activated_establishments
    html = "<div id=\"establishments\" class=\"resources\">"
    unless establishments.empty?
      html << render(:partial => 'establishments/establishment_in_one_line', :collection => establishments, :locals => { :owner_type => owner.class.name.underscore })
    else
      html << "<p>Aucun établissement n'a été trouvé</p>"
    end
    html << "</div>"
  end
  
  def display_establishment_add_button(owner, options = {})
    return unless Establishment.can_add?(current_user)
    
    link_name = options.delete(:link_name) || "Ajouter un établissement"
    
    content_tag :p do
      link_to_remote link_name, { :update    => :establishments,
                                  :position  => :bottom,
                                  :url       => send("new_establishment_path", :owner_type => owner.class.name.underscore),
                                  :method    => :get }.merge(options)
    end
  end
end
