module ForwardersHelper
  
  def generate_forwarder_contextual_menu_partial(forwarder = nil)
    render :partial => 'forwarders/contextual_menu', :object => forwarder
  end
  
  def display_forwarders_list(owner = nil)
    return unless Forwarder.can_list?(current_user)
    if owner
      forwarders = owner.activated_forwarders
    else
      forwarders = Forwarder.all
    end
    html = "<div id=\"forwarders\" class=\"resources\">"
    unless forwarders.empty?
      html << render(:partial => 'forwarders/forwarder_in_one_line', :collection => forwarders, :locals => { :forwarders_owner => owner }) unless forwarders.empty?
    else
      html << "<p>Aucun transporteur n'a été trouvé</p>"
    end
    html << "</div>"
  end
  
  def display_forwarders_list_button(message = nil)
    return unless Forwarder.can_list?(current_user)
    text = "Liste des transporteurs"
    message ||= " #{text}"
    link_to( image_tag( "list_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             forwarders_path)
  end
  
  def display_forwarder_show_button(forwarder, message = nil)
    return unless PurchaseOrder.can_view?(current_user) and !forwarder.new_record?
    text = "Voir ce transporteur"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             forwarder_path(forwarder) )
  end
  
  def display_forwarder_add_button(message = nil)
    return unless Forwarder.can_add?(current_user)
    text = "Nouveau transporteur"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_forwarder_path)
  end
  
  def display_forwarder_edit_button(forwarder, message = nil)
    return unless Forwarder.can_edit?(current_user)
    text = "Modfifier transporteur"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_forwarder_path(forwarder))
  end
  
  def display_forwarder_delete_button(forwarder, message = nil)
#    return unless Forwarder.can_delete?(current_user) and forwarder.can_be_destroyed?
    text = "Supprimer ce transporteur"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             forwarder_deactivate_path(forwarder), :confirm => "Êtes vous sûr?")
  end
  
  def display_forwarder_buttons(forwarder)
    html = []
    html << display_forwarder_show_button(forwarder, "")
    html << display_forwarder_edit_button(forwarder, "")
    html << display_forwarder_delete_button(forwarder, "")
    html.compact.join("&nbsp;")
  end
  
end
