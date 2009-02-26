module SocietyActivitySectorsHelper
  
  # This method permit to show or hide add button
  def show_add_button(txt="")
    if controller.can_add?(current_user)
      return link_to(image_tag("/images/add_16x16.png", :alt => "Ajouter", :title => "Ajouter")+" #{txt}", new_society_activity_sector_path)
    end
  end
  
  # This method permit to test permission for edit button
  def show_edit_button(society_activity_sector,txt="")
    if controller.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier")+" #{txt}", edit_society_activity_sector_path(society_activity_sector))
    end
  end
  
  # This method permit to test permission for delete button
  def show_delete_button(society_activity_sector,txt="")
    if controller.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => 'Supprimer')+" #{txt}", society_activity_sector, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end

end
