module CheckingsHelper
  
  def previous_week(employee_id, date, cancelled)
    link_to "semaine pr&eacute;c&eacute;dente", checkings_path({:date => date.last_week, :employee_id => employee_id, :cancelled => cancelled})
  end
  
  def next_week(employee_id, date, cancelled)
    link_to "semaine suivante", checkings_path({:date => date.next_week, :employee_id => employee_id, :cancelled => cancelled})
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
  
  def checkings_link(employee_id, date, cancelled = true)
    if cancelled
      message = "voir les pointages annul&eacute;s"
      txt = "#{image_tag( "/images/list_16x16.png",:alt => '', :title => "#{message}")} #{message}"
    else
      message = "cacher les pointages annul&eacute;s"
      txt = "#{image_tag( "/images/list_16x16.png",:alt => '', :title => "#{message}")} #{message}"
    end
    link_to txt, checkings_path({:employee_id => employee_id, :cancelled => cancelled, :date => date}) 
  end
  
  def javascript_location_url(date, cancelled)
    html = "window.location.href='checkings?"
    html += "employee_id=" + "'+ this.options[this.selectedIndex].value +'"
    html += "&amp;" + "date=" + "#{date}"
    html += "&amp;" + "cancelled=" + "#{cancelled}" unless cancelled.nil?
    html += "'"
  end
end
