module SuppliersHelper
  
  # This method permit to test permission for add button
  def display_add_button
    if controller.can_add?(current_user) and Supplier.can_add?(current_user)
      add_button = []
      add_button << "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1><ul><li>"
      add_button << link_to("<img src='/images/add_16x16.png' alt='Ajouter' title='Ajouter' /> Ajouter un fournisseur", new_supplier_path)
      return add_button << "</li></ul>"
    end
  end
  
  # This method permit to test pemrission for view button
  def display_view_button(supplier)
    if controller.can_view?(current_user) and Supplier.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails"), supplier_path(supplier)) 
    end
  end
  
  # This method permit to test pemrission for edit button
  def display_edit_button(supplier)
    if controller.can_edit?(current_user) and Supplier.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_supplier_path(supplier)) 
    end
  end
  
  # This method permit to test permission for delete button
  def display_delete_button(supplier)
    if controller.can_delete?(current_user) and Supplier.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer"), supplier, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end
  
end