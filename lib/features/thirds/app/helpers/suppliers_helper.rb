module SuppliersHelper
  
  # This method permit to test permission for add button
  def show_add_button(txt="")
    if controller.can_add?(current_user) and Supplier.can_add?(current_user)
      link_to("#{image_tag("/images/add_16x16.png", :alt => "Ajouter", :title => "Ajouter")} #{txt}", new_supplier_path)
    end
  end
  
  # This method permit to test pemrission for view button
  def show_view_button(supplier,txt="")
    if controller.can_view?(current_user) and Supplier.can_view?(current_user)
      link_to("#{image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails")} #{txt}", supplier_path(supplier)) 
    end
  end
  
  # This method permit to test pemrission for edit button
  def show_edit_button(supplier,txt="")
    if controller.can_edit?(current_user) and Supplier.can_edit?(current_user)
      link_to("#{image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier")} #{txt}", edit_supplier_path(supplier)) 
    end
  end
  
  # This method permit to test permission for delete button
  def show_delete_button(supplier,txt="")
    if controller.can_delete?(current_user) and Supplier.can_delete?(current_user)
      link_to("#{image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer")} #{txt}", supplier, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end
  
end
