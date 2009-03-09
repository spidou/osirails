module ThirdsHelper
  
  # display the add button according to the permissions
  # +text+ is the label link which can be displayed near to the image
  #   if +text+ has the '%' symbol, it is replaced by the name of the third kind (customer or supplier)
  # ==== Examples
  # show_third_add_button(Customer.new)
  #   # <a href="..."><img src="..."></a>  
  # 
  # show_third_add_button(Customer.new, "New %")
  #   # <a href="..."><img src="..."> New customer</a>
  #
  def show_third_add_button(third, text = "")
    third_kind = kind_of_third(third)
    if controller.can_add?(current_user) and third.class.can_add?(current_user)
      link_to(image_tag("/images/add_16x16.png", :alt => "Ajouter", :title => "Ajouter") + " #{parse_link_to_text(third_kind, text)}", send("new_#{third_kind}_path"))
    end
  end
  
  # display the view button according to the permissions
  # +text+ is the label link which can be displayed near to the image
  #   if +text+ has the '%' symbol, it is replaced by the name of the third kind (customer or supplier)
  # ==== Examples
  #   see 'show_third_add_button'
  #
  def show_third_view_button(third, text = "")
    third_kind = kind_of_third(third)
    if controller.can_view?(current_user) and third.class.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt =>"D&eacute;tails", :title =>"D&eacute;tails") + " #{parse_link_to_text(third_kind, text)}", send("#{third_kind}_path", third))
    end
  end
  
  # display the edit button according to the permissions
  # +text+ is the label link which can be displayed near to the image
  #   if +text+ has the '%' symbol, it is replaced by the name of the third kind (customer or supplier)
  # ==== Examples
  #   see 'show_third_add_button'
  def show_third_edit_button(third, text = "")
    third_kind = kind_of_third(third)
    if controller.can_edit?(current_user) and third.class.can_edit?(current_user)
      link_to(image_tag("/images/edit_16x16.png", :alt =>"Modifier", :title =>"Modifier") + " #{parse_link_to_text(third_kind, text)}", send("edit_#{third_kind}_path", third))
    end
  end
  
  # display the delete button according to the permissions
  # +text+ is the label link which can be displayed near to the image
  #   if +text+ has the '%' symbol, it is replaced by the name of the third kind (customer or supplier)
  # ==== Examples
  #   see 'show_third_add_button'
  def show_third_delete_button(third, text = "")
    third_kind = kind_of_third(third)
    if controller.can_delete?(current_user) and third.class.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer") + " #{parse_link_to_text(third_kind, text)}", third, {:method => :delete, :confirm => 'Etes vous s&ucirc;r ?'})
    end
  end
  
  # display the add button for supplier with the correct label
  # it is a shortcut to display the add button in the secondary menu
  def show_supplier_add_button
    show_third_add_button(Supplier.new, "New %") 
  end
  
  # display the add button for customer with the correct label
  # it is a shortcut to display the add button in the secondary menu
  def show_customer_add_button
    show_third_add_button(Customer.new, "New %") 
  end
  
  private
    def kind_of_third(third)
      raise TypeError, "third must be an instance of Customer or Supplier. #{third}:#{third.class}" unless third.kind_of?(Third)
      if third.kind_of?(Customer)
        "customer"
      elsif third.kind_of?(Supplier)
        "supplier"
      else
        raise "This kind of Third has not been implemented yet in the ThirdsHelper. #{third}:#{third.class}"
      end
    end
    
    def parse_link_to_text(third_kind, text)
      text.gsub("%", third_kind)
    end
  
end
