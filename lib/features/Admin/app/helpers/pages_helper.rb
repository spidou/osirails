module PagesHelper
  
  # This method permit to show or not show a button for up a page
  def show_up_button(page)
    link_to(image_tag("url", :alt =>"Monter"), { :action => "move_up", :id => page.id }) if page.can_move_up?
  end
  
   # This method permit to show or not show a button for down a page
  def show_down_button(page)
    link_to(image_tag("url", :alt => "Descendre"), { :action => "move_down", :id => page.id }) if page.can_move_down?
  end
  
  # This method permit to show or not show a button for delete a page
  def show_delete_button(page)
    link_to("Supprimer", page, {:method => :delete}) unless page.base_item?
  end
end
