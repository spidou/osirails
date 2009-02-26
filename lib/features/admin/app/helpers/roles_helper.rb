module RolesHelper
  
  # to get a preview  of the string
  def preview(string,length)
    return "Pas de description disponible" if string.nil?
    string.length>length ? string[0,length] +" (...)" : string 
  end
  
  # This method permit to test permission for edit button
  def show_edit_button(role,txt="")
    if controller.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier")+" #{txt}", edit_role_path(role))
    end
  end
  
  # This method permit to test permission for view button
  def show_view_button(role,txt="")
    if controller.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails")+" #{txt}", role_path(role)) 
    end
  end
  
  # This method permit to test permission for delete button
  def show_delete_button(role,txt="")
    if controller.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => 'Supprimer')+" #{txt}", role, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end
  
  # This method permit to show or hide add button
  def show_add_button(txt="")
    if controller.can_add?(current_user)
      return link_to(image_tag("/images/add_16x16.png", :alt => "Ajouter", :title => "Ajouter")+" #{txt}", new_role_path)

    end
  end
  
end
