module LeavesHelper

  def get_current_leave_year(shift=0)
    leave_year_start_date = Employee.get_leave_year_start_date + shift.year
    today = Date.today + shift.year
    (leave_year_start_date.year != today.year)? "#{today.year-1}/#{today.year}" : today.year 
  end
  
  def get_leave_years_select(employee, after)
    unless employee.job_contract.nil? or employee.job_contract.start_date.nil?
      before = employee.job_contract.start_date.year - Date.today.year
      html = "<select name='leave_year_shift'>"
      (before..-1).each do |i|
        html += "<option value='#{i}'>#{ get_current_leave_year(i)}</option>"
      end
    end
    html += "<option selected='selected' value='0'>#{ get_current_leave_year }</option>"
    (1..after).each do |j|
      html += "<option value='#{j}'>#{ get_current_leave_year(j)}</option>"
    end
    html += "</select>"
  end
  
  def get_effective_leave_periode(leave, leave_year_start_date)
    html = "du <strong>#{leave.start_date.strftime("%d %b %Y")}</strong>"
    html += leave.start_half ? " (apr&egrave;s-midi) " : " "
    html += "jusqu'au <strong>#{leave.end_date.strftime("%d %b %Y")}</strong> "
    html += leave.end_half ? "(matin&e&cute;e)" : ""
  end
end
