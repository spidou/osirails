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
    return User.find(session[:user_id]) if session[:user_id] # TODO Add the :include option for the employee table
  end
end
