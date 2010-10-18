module ConveyancesHelper
  
  def generate_conveyance_contextual_menu_partial(conveyance = nil)
    render :partial => 'conveyances/contextual_menu', :object => conveyance
  end
  
  def display_conveyances_list(owner = nil)
    return unless Conveyance.can_list?(current_user)
    if owner
      conveyances = owner.activated_conveyances
    else
      conveyances = Conveyance.all
    end
    html = "<div id=\"conveyances\" class=\"resources\">"
    unless conveyances.empty?
      html << render(:partial => 'conveyances/conveyance_in_one_line', :collection => conveyances, :locals => { :conveyances_owner => owner }) unless conveyances.empty?
    else
      html << "<p>Aucun moyen de transport n'a été trouvé</p>"
    end
    html << "</div>"
  end
  
  def display_conveyances_list_button(message = nil)
    return unless Conveyance.can_list?(current_user)
    text = "Liste des moyens de transport"
    message ||= " #{text}"
    link_to( image_tag( "list_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             conveyances_path)
  end
  
  def display_conveyance_add_button(message = nil)
    return unless Conveyance.can_add?(current_user)
    text = "Nouveau moyen de transport"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_conveyance_path)
  end
  
  def display_conveyance_edit_button(conveyance, message = nil)
    return unless Conveyance.can_edit?(current_user)
    text = "Modfifier ce moyen de transport"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_conveyance_path(conveyance))
  end
  
  def display_conveyance_delete_button(conveyance, message = nil)
    return unless Conveyance.can_delete?(current_user) and conveyance.can_be_destroyed?
    text = "Supprimer ce moyen de transport"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             conveyance, :method => :delete, :confirm => "Êtes vous sûr?")
  end
  
  def display_conveyance_buttons(conveyance)
    html = []
    html << display_conveyance_edit_button(conveyance, "")
    html << display_conveyance_delete_button(conveyance, "")
    html.compact.join("&nbsp;")
  end
  
  def display_conveyance_add_button_for_owner(owner, message = "Ajouter un moyen de transport")
    owner_type = owner.class.name.downcase
    content_tag( :p, link_to_function message do |page|
      page.insert_html :bottom, "#{owner_type}_conveyances".to_sym, :partial => 'conveyances/conveyance_in_one_line_for_owner',
                       :object  => Conveyance.new,
                       :locals  => { :conveyance_owner => owner }
      last_element = page["#{owner_type}_conveyances"].select('.resource').last
      last_element.visual_effect "highlight" # :highlight symbol replaced by "highlight" string to relieve to the "undefined method `ascii_only?' for {}:Hash" error, in views
    end )
  end
  
  def display_conveyance_buttons_for_owner(conveyance)
    html = []
    html << display_conveyance_delete_button_for_owner(conveyance, "")
    html.compact.join("&nbsp;")
  end
  
  def display_conveyance_delete_button_for_owner(conveyance, message = nil)
    if conveyance.new_record?
      link_to_function(image_tag("cross_16x16.png"), "this.up('.resource').remove();")
    else
      link_to_function(image_tag("cross_16x16.png"), "if (confirm('Êtes-vous sûr? Attention, les modifications seront appliquées à la soumission du formulaire.')) mark_resource_for_destroy(this.up('.resource'));")
    end
  end
  
end
