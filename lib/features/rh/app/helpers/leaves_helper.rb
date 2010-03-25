module LeavesHelper
  
  def get_leave_years_select(employee, current_year = nil)
    return if employee.job_contract.nil? or employee.job_contract.start_date.nil?
    
    current_year ||= Employee.leave_year_start_date.year
    first_year     = employee.job_contract.start_date.year
    last_year      = employee.last_leave ? employee.last_leave.end_date.year : Date.today.year

    html = "<select name='leave_year' onchange='submit();' >"  
    (first_year..last_year).each do |year|
      selected = (year == current_year.to_i)? "selected='selected'" : ""
      html += "<option #{ selected } value='#{ year }'>#{ year }</option>"
    end  
    html += "</select>"
  end
  
  def leaves_link(employee, cancelled = true)
    text = cancelled ? "Voir tous les congés annulés" : "Voit tous les congés"
    link_to(image_tag("list_16x16.png", :alt => text, :title => text) + " #{text}", employee_leaves_path({:cancelled => cancelled}))
  end
  
  def cancel_image
    image_tag("cancel_16x16.png", :alt => "Annuler ce congé", :title => "Annuler ce congé")
  end
  
  def cancel_employee_leave_link(employee, leave)
    link_to(cancel_image, cancel_employee_leave_path(employee, leave), :confirm => "Êtes-vous sûr ?")
  end
  
end
