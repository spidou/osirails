module LeavesHelper
  
  def get_leave_years_select(employee, after, current_year = nil)
    return if employee.job_contract.nil? or employee.job_contract.start_date.nil?
    
    current_year ||= Employee.leave_year_start_date.year
    after = nil if after < 0   
    last_year = Employee.leave_year_start_date.year + (after || 0)
    
    html = "<select name='leave_year' onchange='submit();' >"   
    (employee.job_contract.start_date.year..last_year).each do |year|
      selected = (year == current_year.to_i)? "selected='selected'" : ""
      html += "<option #{ selected } value='#{ year }'>#{ year }</option>"
    end  
    html += "</select>"
  end
  
  def get_effective_leave_periode(leave)
    html = "du <strong>#{leave.start_date.strftime("%d %B %Y")}"
    html += leave.start_half ? " (apr&egrave;s-midi) " : " "
    html += "</strong>"
    html += "au <strong>#{leave.end_date.strftime("%d %B %Y")}"
    html += leave.end_half ? " (matin&eacute;e)" : " "
    html += "</strong>"
  end
  
  def leaves_link(employee, cancelled = true)
  if cancelled
    message = "voir les cong&eacute;s annul&eacute;s"
    txt = "#{image_tag( "/images/list_16x16.png",:alt => '', :title => "#{message}")} #{message}"
  else
    message = "cacher les cong&eacute;s annul&eacute;s"
    txt = "#{image_tag( "/images/list_16x16.png",:alt => '', :title => "#{message}")} #{message}"
  end
  link_to txt, employee_leaves_path({:cancelled => cancelled}) 
  end
  
end
