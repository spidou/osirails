module MenusHelper
  
  # This method permit to show or not show button for up menu
  def show_up_button(menu, first_menu)
    if controller.can_edit?(current_user)
    
      if menu.can_move_up? and !first_menu
        link_to(image_tag("/images/arrow_up_16x16.png", :alt => "Up", :title => "Up"), move_up_menu_path(menu))
      else
        image_tag("/images/arrow_up_disable_16x16.png", :alt => "Up", :title => "Up")
      end
    end
  end
  
  # This method permit to show or not show button for down menu
  def show_down_button(menu, last_menu)
    if controller.can_edit?(current_user)
      if menu.can_move_down? and !last_menu
        link_to(image_tag("/images/arrow_down_16x16.png", :alt => "Down", :title => "Down"), move_down_menu_path(menu))
      else
        image_tag("/images/arrow_down_disable_16x16.png", :alt => "Down", :title => "Down")
      end
    end
  end
  
  # This method permit to show or not show button for delete menu
  def show_delete_button(menu)
    if controller.can_delete?(current_user)
      unless menu.base_item?
        link_to(image_tag("/images/delete_16x16.png", :alt =>"Delete", :title =>"Delete"), menu, {:method => :delete, :confirm => 'Etes vous sûr  ?' })
      else
        image_tag("/images/delete_disable_16x16.png", :alt =>"Delete", :title =>"Delete")
      end
    end
  end
  
  # This method permit to show or hide button for add menu
  def new_menu_link_with_parent(menu,txt="New menu")
    if controller.can_add?(current_user)
      link_to(image_tag("/images/add_16x16.png", :alt => txt, :title => txt)+" #{txt}", new_menu_path(:parent_menu_id => menu.id))
    end
  end
  
  # This method permit to have a menu on <ul> type.
  def show_structured_menus(menus)
    list = []
    list << "<div class='hierarchic'><ul class=\"parent\">"
    list = get_children_menus(menus,list)
    list << "</ul></div>"
    list 
  end
  
  # This method permit to make a tree for menus
  def get_children_menus(menus,list)
    menus.each do |menu|
      first_menu = ( menus.first == menu ? true : false )
      last_menu = ( menus.last == menu ? true : false )
			menu.base_item? ? delete_button = "" : delete_button = delete_menu_link(menu,:link_text => "")
      list << "<li class=\"category\">#{menu.title}<span class=\"action\">#{show_up_button(menu, first_menu)} #{show_down_button(menu, last_menu)} #{new_menu_link_with_parent(menu,"")} #{edit_menu_link(menu,:link_text => "")} #{delete_button}</span></li>"
      if menu.children.size > 0
        list << "<ul>"
        get_children_menus(menu.children,list)
        list << "</ul>"
      end
    end
    list
  end
end
