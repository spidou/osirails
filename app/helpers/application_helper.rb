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
  
  def display_main_menu
    html = ""
    menu = current_menu
    Menu.mains.each do |m|
      selected = (m == menu or m.children.include?(menu) ? "class=\"selected\"" : "")
      html << "<li #{selected} title=\"#{m.description}\"><a href=\"\">#{m.title}</a></li>\n"
    end
    html
  end
  
  def display_second_menu
    html = []
    main_menu = current_menu.parent_menu
    main_menu.children.each do |m|
      first =  main_menu.children.first == m ? "id=\"menu_horizontal_first\"": "" #detect if is the first element
      selected = (m == current_menu ? "class=\"selected\"" : "") #detect if the element is selected
      html << "<a href=\"\" title=\"#{m.description}\"><span #{selected} #{first}>#{m.title}</span></a>"
    end
    html.reverse.to_s
  end
end
