module CheckingsHelper
  
  def previous_week(params)
    link_to "semaine pr&eacute;c&eacute;dente", checkings_path({:date => params[:date].to_date.last_week, :employee_id => params[:employee_id]})
  end
  
  def next_week(params)
    link_to "semaine suivante", checkings_path({:date => params[:date].to_date.next_week, :employee_id => params[:employee_id]})
  end
  
  def employee_options(employees, params)
    html = ""
    employees.each do |employee|
      selected = (employee.id == params[:employee_id].to_i)? "selected='selected'" : ""
      html += "<option #{selected} value='#{employee.id}'>#{employee.fullname}</option>"
    end 
    html
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
  
end
