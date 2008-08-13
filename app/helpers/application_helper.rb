# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def file_upload
    file_field 'upload', 'datafile'
  end
  
  def display_flash
    unless flash[:error].nil?
      return "<p class='flashError'>" + flash[:error] + "</p>"
    end
    unless flash[:notice].nil?
      return "<p class='flashNotice'>" + flash[:notice] + "</p>"
    end
  end
  
  def current_user
    session[:user]
  end
  
  def current_menu
    Menu.find_by_name(controller.controller_name) or raise "The controller '#{controller.controller_name}' should have a menu with the same name"
  end
  
  def link_to_menu(menu, content = nil)
    # OPTIMIZE optimize this IF block code
    if self.respond_to?(menu.name + "_path")
      link_to(content || menu.title, self.send(menu.name + "_path"))
    else
      link_to(content || menu.title, :controller => menu.name)
    end
  end
  
  def display_main_menu
    html = ""
    menu = current_menu
    Menu.mains.each do |m|
      selected = (menu == m or menu.ancestors.include?(m) ? "class=\"selected\"" : "")
      html << "<li #{selected} title=\"#{m.description}\">" + link_to_menu(m) + "</li>\n"
    end
    html
  end
  
  def display_second_menu
    html = []
    menu = current_menu
    main_menu = menu.last_ancestor
    #return if main_menu.nil?
    main_menu.children.each do |m|
      first = main_menu.children.first == m ? "id=\"menu_horizontal_first\"": "" #detect if is the first element
      selected = ( ( menu == m or menu.ancestors.include?(m) ) ? "class=\"selected\"" : "") #detect if the element is selected
      #html << "<a href=\"\"><span title=\"#{m.description}\" #{selected} #{first}>#{m.title}</span></a>"
      html << link_to_menu(m, "<span title=\"#{m.description}\" #{selected} #{first}>#{m.title}</span></a>")
    end
    html.reverse.to_s
  end
end
