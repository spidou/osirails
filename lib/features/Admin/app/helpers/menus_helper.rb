module MenusHelper
  
  # This method permit to show or not show a button for up a menu
  def show_up_button(menu)
    link_to(image_tag("/images/up_arrow.png", :alt =>"Monter"), { :action => "move_up", :id => menu.id }) if menu.can_move_up?
  end
  
  # This method permit to show or not show a button for down a menu
  def show_down_button(menu)
    link_to(image_tag("/images/down_arrow.png", :alt => "Descendre"), { :action => "move_down", :id => menu.id }) if menu.can_move_down?
  end
  
  # This method permit to show or not show a button for delete a menu
  def show_delete_button(menu)
    " &#124; " + link_to("Supprimer", menu, {:method => :delete, :confirm => 'Etes vous sûr  ?' }) unless menu.base_item?
  end
  
  # This method permit to have a menu on <ul> type.
  def show_structured_menu
    menus = Menu.find_all_by_parent_id(:order => "position")
    list = []
    list << "<div class='hierarchic'><ul class=\"parent\">"
    list = get_children(menus,list)
    list << "</ul></div>"
    list 
  end
  
  # This method permit to make a tree for menus
  def get_children(menus,list)
    menus.each do |menu|
      delete_button = show_delete_button(menu)
      up_button = show_up_button(menu)
      down_button = show_down_button(menu)
      list << "<li class=\"category\">#{menu.title} &nbsp; <span class=\"action\">#{up_button} #{down_button} "+link_to("Modifier", edit_menu_path(menu))+" #{delete_button}</span></li>"

      if menu.children.size > 0
        list << "<ul>"
        get_children(menu.children,list)
        list << "</ul>"
      end
    end
    list
  end
  
end