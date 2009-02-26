module CustomersHelper
  
  # This method permit to test permission for add button
  def show_customer_add_button(txt="")
    if controller.can_add?(current_user) and Customer.can_add?(current_user)
      link_to("#{image_tag("/images/add_16x16.png", :alt => "Ajouter", :title => "Ajouter")} #{txt}", new_customer_path)

    end
  end
  
  # This method permit to test pemission for view button
  def show_customer_view_button(customer,txt="")
    if controller.can_view?(current_user) and Customer.can_view?(current_user)
      link_to("#{image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails")} #{txt}", customer_path(customer)) 
    end
  end
  
  # This method permit to test pemission for edit button
  def show_customer_edit_button(customer,txt="")
    if controller.can_edit?(current_user) and Customer.can_edit?(current_user)
      link_to("#{image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier")} #{txt}", edit_customer_path(customer)) 
    end
  end
  
  # This method permit to test permission for delete button
  def show_customer_delete_button(customer,txt="")
    if controller.can_delete?(current_user) and Customer.can_delete?(current_user)
      link_to("#{image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer")} #{txt}", customer, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end
  
end
