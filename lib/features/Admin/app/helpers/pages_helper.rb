module PagesHelper
  
  # This method permit to show or not show a button for move a page
  def show_move_buttons(page)
    buttons = []
    if page.move_up?
      buttons << link_to(image_tag("up", :alt =>"up"), { :action => "move_up", :id => page.id })      
    end
    if page.move_down?
      buttons << link_to(image_tag("down", :alt => "down"), { :action => "move_down", :id => page.id })
    end
    buttons
  end
  
  # This method permit to show or not show a button for delete a page
  def show_delete_button(page)
    link_to("Delete", { :action => "destroy", :id => page.id }) unless page.base_item?
  end
end
