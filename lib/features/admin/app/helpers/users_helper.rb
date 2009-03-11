module UsersHelper

  # This method permit to test permission for edit button
  def show_edit_button(user,txt="")
    if controller.can_edit?(current_user)
      link_to("#{image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier")} #{txt}", edit_user_path(user))
    end
  end
  
  # This method permit to test permission for view button
  def show_view_button(user,txt="")
    if controller.can_view?(current_user)
      link_to("#{image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails")} #{txt}" , user_path(user)) 
    end
  end

  # This method permit to test permission for view button
  def show_delete_button(user,txt="")
    if controller.can_view?(current_user)
      link_to("#{image_tag("/images/delete_16x16.png", :alt =>"<Supprimer", :title =>"Supprimer")} #{txt}", user, {:method => :delete , :confirm => 'Etes vous s&ucirc;r ?' } ) 

    end
  end
  
  # This method permit to show or hide add button
  def show_add_button(txt="")
    if controller.can_add?(current_user)
      link_to("#{image_tag("/images/add_16x16.png", :alt => "Ajouter", :title => "Ajouter")} #{txt}", new_user_path)
    end
  end
end
