module ProductReferenceManagerHelper
  
  # This method permit to show or hide delete button
  def show_delete_button(category)
    " &brvbar; " + link_to("Supprimer", category, { :method => :delete } ) if category.can_delete? == true
  end
  
end
