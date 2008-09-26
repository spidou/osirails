module SocietyActivitySectorsHelper
  
  # This method permit to show or hide add button
  def show_add_button
    if controller.can_add?(current_user)
      add_button = []
      add_button << "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1><ul><li>"
      add_button << link_to("<img src='/images/add_16x16.png' alt='Ajouter' title='Ajouter' /> Ajouter un secteur d'ativit&eacute;", new_society_activity_sector_path)
      return add_button << "</li></ul>"
    end
  end
  
  # This method permit to test permission for edit button
  def show_edit_button(society_activity_sector)
    if controller.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_society_activity_sector_path(society_activity_sector))
    end
  end
  
  # This method permit to test permission for delete button
  def show_delete_button(society_activity_sector)
    if controller.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => 'Supprimer'), society_activity_sector, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end

end
