module UsersHelper

  # This method permit to test permission for edit button
  def show_edit_button(user)
    if controller.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_user_path(user))
    end
  end
  
  # This method permit to test permission for view button
  def show_view_button(user)
    if controller.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails"), user_path(user)) 
    end
  end
  
  # This method permit to show or hide add button
  def show_add_button
    if controller.can_add?(current_user)
      add_button = []
      add_button << "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1><ul><li>"
      add_button << link_to("<img src='/images/add_16x16.png' alt='Ajouter' title='Ajouter' /> Ajouter un utilisateur", new_user_path)
      return add_button << "</li></ul>"
    end
  end

end
