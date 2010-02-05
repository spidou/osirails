module CheckingsHelper
  
  def previous_week(employee_id, date, cancelled)
    link_to "semaine précédente", checkings_path({:employee_id => employee_id, :date => date.last_week, :cancelled => cancelled})
  end
  
  def next_week(employee_id, date, cancelled)
    link_to "semaine suivante", checkings_path({:employee_id => employee_id, :date => date.next_week, :cancelled => cancelled})
  end
  
  def employee_options(employees, employee_id)
    employees.collect {|employee| "<option #{employee.id == employee_id ? "selected='selected'" : ""} value='#{employee.id}'>#{employee.fullname}</option>" }.join
  end
  
  def generate_absence_and_overtime_td(checking)
    attributes_array = [ [checking.absence_comment, checking.absence_hours||=0, checking.absence_minutes||=0],
                         [checking.overtime_comment, checking.overtime_hours||=0, checking.overtime_minutes||=0]]
    html = ""
    attributes_array.each do |attribute|
      if attribute[1] == 0 and attribute[2] == 0
        html += "<td>-</td>" 
      else
        html += "<td title=\"#{attribute[0]}\">"
        html += "#{attribute[1]} h " unless attribute[1] == 0
        html += "#{attribute[2]} min" unless attribute[2] == 0
        html += "</td>"
      end
    end
    html    
  end
  
  def display_checkings_link(employee_id = nil, cancelled = false)
    link_options = { :employee_id => employee_id, :date => params[:date] }
    
    if params[:cancelled] == "true" or cancelled
      options = { :link_text => "Liste des pointages", :options => link_options }
    else
      options = { :link_text => "Voir les pointages annulés", :options => link_options.merge({ :cancelled => true }) }
    end
    
    checkings_link(options)
  end
  
  def javascript_location_url(employee_id, date, cancelled)
    html = "window.location.href='checkings?"
    html += "employee_id="    + "'+ this.options[this.selectedIndex].value +'"
    html += "&amp;date="      + date
    html += "&amp;cancelled=" + cancelled if cancelled
    html += "'"
  end
  
  def cancel_image
    image_tag("/images/delete_16x16.png", :alt => "Annuler ce pointage",:title => "Annuler ce pointage")
  end
  
  def override_image
    image_tag("/images/edit_16x16.png", :alt => "Corriger ce pointage",:title => "Corriger ce pointage")
  end
  
  def cancel_checking_link(checking)
    link_to(cancel_image, cancel_checking_path(checking), :confirm => "Êtes-vous sûr ?") if checking.can_be_cancelled? and Checking.can_cancel?(current_user)
  end
  
  def override_checking_link(checking)
    link_to(override_image, override_form_checking_path(checking)) if checking.can_be_overrided? and Checking.can_override?(current_user)
  end
end
