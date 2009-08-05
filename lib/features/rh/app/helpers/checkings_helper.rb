module CheckingsHelper

  def absence_meaning(absence)
    txt = ["Aucune","Matin&eacute;e", "Apr&eacute;s-midi", "Journ&eacute;e"]
    txt[absence||=0]
  end
  
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
  
  def generate_overtime_and_delay_td(checking)
    attributes_array = [ [checking.morning_overtime_comment, checking.morning_overtime_hours||=0, checking.morning_overtime_minutes||=0],
                         [checking.afternoon_overtime_comment, checking.afternoon_overtime_hours||=0, checking.afternoon_overtime_minutes||=0],
                         [checking.morning_delay_comment, checking.morning_delay_hours||=0, checking.morning_delay_minutes||=0],
                         [checking.afternoon_delay_comment, checking.afternoon_delay_hours||=0, checking.afternoon_delay_minutes||=0]]
    html = ""
    attributes_array.each do |attribute|
      if attribute[1]==0 and attribute[2]==0
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
