module MenusHelper
  
  # This method permit to show or not show button for up menu
  def show_up_button(menu, first_menu)
    if Menu.can_edit?(current_user)
    
      if menu.can_move_up? and !first_menu
        link_to(image_tag("/images/arrow_up_16x16.png", :alt => "Up", :title => "Up"), move_up_menu_path(menu))
      else
        image_tag("/images/arrow_up_disable_16x16.png", :alt => "Up", :title => "Up")
      end
    end
  end
  
  # This method permit to show or not show button for down menu
  def show_down_button(menu, last_menu)
    if Menu.can_edit?(current_user)
      if menu.can_move_down? and !last_menu
        link_to(image_tag("/images/arrow_down_16x16.png", :alt => "Down", :title => "Down"), move_down_menu_path(menu))
      else
        image_tag("/images/arrow_down_disable_16x16.png", :alt => "Down", :title => "Down")
      end
    end
  end
  
  # This method permit to show or not show button for delete menu
  def show_delete_button(menu)
    if Menu.can_delete?(current_user)
      unless menu.base_item?
        link_to(image_tag("/images/delete_16x16.png", :alt =>"Delete", :title =>"Delete"), menu, {:method => :delete, :confirm => 'Etes vous sûr  ?' })
      else
        image_tag("/images/delete_disable_16x16.png", :alt =>"Delete", :title =>"Delete")
      end
    end
  end
  
  # This method permit to show or hide button for add menu
  def new_menu_link_with_parent(menu,txt="New menu")
    if Menu.can_add?(current_user)
      link_to(image_tag("/images/add_16x16.png", :alt => txt, :title => txt)+" #{txt}", new_menu_path(:parent_menu_id => menu.id))
    end
  end
  
  # This method permit to have a menu on <ul> type.
  def show_structured_menus(menus)
    get_children_menus(menus, "<div class='hierarchic'><ul class='parent'>") + "</ul></div>"
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
  
  ########################################## 
  
  # Method to get all structured menus into an array
  #
  def get_all_menus_structured
    root_menus = Menu.all(:conditions => ['parent_id is NULL'], :order => :position)
    menus      = []
    root_menus.each do |menu|
      menus << menu.get_structured_children
    end
    menus
  end
  
  # Method to get structured menus into uls to manage +roles_permissions+
  # - +menus+ is an Array, it chould be 'get_all_menus_structured'
  # - +filter+ is an Array, containing all permissions (one for each menu, it permit to discards menus without permissions if there is).
  #
  def get_structured_menus_permissions(menus, filter)
    result = "<ul class='parent'>"
    menus.each do |menu|
      if menu.is_a?(Array)
        children = get_structured_menus_permissions(menu.last, filter)
        menu     = menu.first
      end
      permission = filter.detect {|n| n.has_permissions_id == menu.id}
      methods    = permission.permission_methods.collect {|method| get_check_box(permission, method)}.join(' ')
      result    += "<li class='category' title='#{ menu.name }'>#{ menu.title }<span class='action'>#{ methods }</span></li>"
      result    += children || ''
    end
    result += "</ul>"
  end
  
  # Method to generate a label, a check_box and an hidden field to
  # be used by +get_structured_menus_permissions+
  #
  def get_check_box(permission, method)
    checked_class = permission.send(method.name) ? 'checked' : 'unChecked'
    name    = "permissions[#{ permission.id }][#{ method.name }]"
    result  = "<label for='#{ name }' class='method #{ checked_class }'>#{ method.name.humanize }</label> "
    result += check_box_tag(name, 1, permission.send(method.name),
                            :class   => 'check_boxes',
                            :onClick => 'tick_children(this);')
    result += "<input name='#{ name }' value='0' type='hidden'"
  end
  
  # Method to get structured uls containing links to manage +menus_permissions+
  #
  def get_structured_menus_links(menus)
    result = "<ul class='parent'>"
    menus.each do |menu|
      if menu.is_a?(Array)
        children = get_structured_menus_links(menu.last)
        menu     = menu.first
      end
      result += "<li class='category' title='#{ menu.name }'>#{ link_to(menu.title, edit_menu_permission_path(menu)) }</li>"
      result += children || ''
    end
    result += "</ul>"
  end
end  
