module CustomersHelper
  
  # This method permit to show or hide action menu
  def display_customer_action_menu(customer)
    if controller.can_edit?(current_user) and Customer.can_edit?(current_user)
      html = ""
      html += "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1>"
      html += "<ul>"
      html +=  "<li>#{display_customer_edit_button(customer)} Modifier le client</li>"
      html += "</ul>"
    end
  end
  
  # This method permit to test permission for add button
  def display_customer_add_button
    if controller.can_add?(current_user) and Customer.can_add?(current_user)
      add_button = []
      add_button << "<h1><span class='gray_color'>Action</span> <span class='blue_color'>possible</span></h1><ul><li>"
      add_button << link_to("<img src='/images/add_16x16.png' alt='Ajouter' title='Ajouter' /> Ajouter un client", new_customer_path)
      return add_button << "</li></ul>"
    end
  end
  
  # This method permit to test pemission for view button
  def display_customer_view_button(customer)
    if controller.can_view?(current_user) and Customer.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails"), customer_path(customer)) 
    end
  end
  
  # This method permit to test pemission for edit button
  def display_customer_edit_button(customer)
    if controller.can_edit?(current_user) and Customer.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier"), edit_customer_path(customer)) 
    end
  end
  
  # This method permit to test permission for delete button
  def display_customer_delete_button(customer)
    if controller.can_delete?(current_user) and Customer.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer"), customer, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end
  
end