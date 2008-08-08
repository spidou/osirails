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
  
  def display_main_menu
    html = ""
    Menu.mains.each do |menu|
      html << "<li><a href=\"\">#{menu.title}</a></li>"
    end
    html
  end
  
  def display_second_menu
    
  end
end
