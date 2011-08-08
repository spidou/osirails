module CheckingsHelper
  
  def checking_action_buttons(checking)
    date = checking.date
    employee = checking.employee
    html = []
    if checking.date <= Date.today
      if checking.new_record?
        html << new_checking_link(:options => { :date => date, :employee_id => employee.id, :as_employee_id => @as_employee_id })
      else
        html << edit_checking_link(checking, :options => { :as_employee_id => @as_employee_id })
        html << delete_checking_link(checking, :options => { :as_employee_id => @as_employee_id })
      end
    end
    html << link_to("Pointer en tant que #{employee.fullname}", checkings_path(:as_employee_id => employee.id, :date => date), 'data-icon' => :check_as_employee) if employee.subordinates.any?  
    html.compact
  end
  
  def calendar_location(as_employee_id)
    calendar = "function(cal){ window.location = 'checkings?"
    calendar += as_employee_id ? 'as_employee_id=' + as_employee_id.to_s + '&' : ""
    calendar += "date=' + cal.date.print('%Y-%m-%d')}" 
  end
  
  def form_calendar_location(as_employee_id,employee_id)
    calendar= "function(cal){ window.location = '/checkings/new?"
    calendar += employee_id ? 'employee_id=' + employee_id.to_s + '&' : ""
    calendar += as_employee_id ? 'as_employee_id=' + as_employee_id.to_s + '&' : ""
    calendar += "date=' + cal.date.print('%Y-%m-%d')}" 
  end
  
  def new_or_edit_action(checking)
    checking.new_record? ? "new" : "edit"
  end
  
  def display_morning_start_td(checking)
    if (checking.is_whole_day_leave? && checking.leaves.count == 1) || checking.absence_is_whole_day?
      colspan = "4"
      class_name = no_worked_class_name_td(checking)
      value = no_worked_value_td(checking)
    elsif checking.leaves.count == 2 || checking.is_morning_leave? || checking.absence_is_morning?
      colspan="2"
      class_name = no_worked_class_name_td(checking)
      value = no_worked_value_td(checking)
      leave_start = checking.leaves.count == 2 ? true : nil
    elsif checking.morning_start_modification? || checking.scheduled_works_morning? && checking.date <= Date.today
      colspan=nil
      if checking.morning_start_hours  > checking.datetime_to_float_hours(Time.now)   && checking.date == Date.today
        class_name = nil
        value = nil
      else
        class_name = morning_start_class_name(checking)
        value = float_hours_to_string(checking.morning_start_hours)
      end
    end
    if colspan.nil?
      popup_hour_modification(class_name, value, checking.working_morning_start_hours, checking.scheduled_morning_start, checking.morning_start_comment)    
    else
      popup_whole_day_information(class_name, value, colspan, checking, leave_start)
    end
  end
  
  def display_morning_end_td(checking)
    return if checking.is_morning_leave?  || checking.is_whole_day_leave? || checking.absence_is_morning? || checking.absence_is_whole_day?
    if checking.morning_end_modification? || checking.scheduled_works_morning? && checking.date <= Date.today
      if checking.morning_end_hours > checking.datetime_to_float_hours(Time.now)   && checking.date == Date.today
        class_name = nil
        value = nil
      else
        class_name = morning_end_class_name(checking)
        value = float_hours_to_string(checking.morning_end_hours)
      end
    end
    popup_hour_modification(class_name,value,checking.working_morning_end_hours,checking.scheduled_morning_end,checking.morning_end_comment)
  end
  
  def display_afternoon_start_td(checking)
    return  if (checking.is_whole_day_leave? && checking.leaves.count == 1) || checking.absence_is_whole_day?
    if checking.is_afternoon_leave? || checking.absence_is_afternoon? 
      colspan="2"
      class_name= no_worked_class_name_td(checking)
      value = no_worked_value_td(checking)
      leave_start = checking.leaves.count == 2 ? false : nil
    elsif  checking.afternoon_start_modification? || checking.scheduled_works_afternoon? && checking.date <= Date.today
      colspan=nil
      if checking.afternoon_start_hours > checking.datetime_to_float_hours(Time.now)   && checking.date == Date.today
        class_name = nil
        value = nil
      else
        class_name = afternoon_start_class_name(checking)
        value = float_hours_to_string(checking.afternoon_start_hours)
      end
    end
    if colspan.nil?
      popup_hour_modification(class_name,value,checking.working_afternoon_start_hours,checking.scheduled_afternoon_start,checking.afternoon_start_comment)
    else
      popup_whole_day_information(class_name,value,colspan,checking,leave_start)
    end
  end
  
  def display_afternoon_end_td(checking)
    return if checking.is_whole_day_leave? || checking.absence_is_whole_day? ||  checking.absence_is_afternoon? || checking.is_afternoon_leave?
    if checking.afternoon_end_modification? || checking.scheduled_works_afternoon? && checking.date <= Date.today
      colspan=nil
      if checking.afternoon_end_hours  > checking.datetime_to_float_hours(Time.now) && checking.date == Date.today
        class_name = nil
        value = nil
      else
        class_name = afternoon_end_class_name(checking)
        value = float_hours_to_string(checking.afternoon_end_hours)
      end
    end
    popup_hour_modification(class_name,value,checking.working_afternoon_end_hours,checking.scheduled_afternoon_end,checking.afternoon_end_comment)
  end
  
  def display_total_worked_hours_td(checking)
    if checking.working_whole_day_hours 
      if checking.is_leave_today? || !checking.scheduled_works_today? && (checking.working_whole_day_hours == 0)
        value = nil
      elsif checking.date == Date.today
        if checking.morning_start_hours > checking.datetime_to_float_hours(Time.now)
          value = nil
        elsif checking.morning_end_hours < checking.datetime_to_float_hours(Time.now)
          value = float_hours_to_string(checking.working_morning_hours)
        elsif checking.afternoon_end_hours < checking.datetime_to_float_hours(Time.now)
          value = float_hours_to_string(checking.working_whole_day_hours)
        end
      else
        value = checking.date < Date.today ? float_hours_to_string(checking.working_whole_day_hours) : nil
      end
    content_tag(:td, value, :class => "total_worked_hours")
    end
  end
  
  def display_balance_hours_td(checking)
    if checking.working_whole_day_hours && checking.balance_worked_hours
      if checking.date <= Date.today
        value = checking.balance_worked_hours != 0 ? add_balance_hours_to_string(checking.balance_worked_hours) : nil
        class_name = checking.balance_worked_hours < 0 ? "delay" : "overtime"
      else
        value = nil
      end
    content_tag(:td, value, :class => class_name)
    end
  end
  
  def float_hours_to_string(float)
    unless float.nil?
      hours = float.to_i
      minutes = hours == 0 ? float : float%hours
      minutes = (minutes*60).to_i < 0 ?  (minutes*60).to_i * -1 : (minutes*60).to_i
      if minutes > 0 && hours == 24
        nil
      else
         result = minutes == 0 ||  minutes == 5 ?  hours.to_s + " H 0" + minutes.to_s : hours.to_s + " H " + minutes.to_s
      end
    end
  end
  
  def add_balance_hours_to_string(float)
    float_hours_to_string(float)[0,1].to_i == 0 ?  float_hours_to_string(float) :  "+ " + float_hours_to_string(float)
  end
  
  def step_hours_to_array_hours_with_step(step_hour)
    array = []
    step_end = 60 - step_hour
    if step_hour == 0
      (0..23).each do |hour|
          array << hour
      end
    else
      (0..23).each do |hour|
        (0..step_end).step(step_hour).each do |step_minutes|
          minutes =(step_minutes/0.6)/100
          array << hour + minutes
        end
      end
    end
    return array
  end
  
  def array_hour_to_hash_hour(array)
    hash_hours = OrderedHash.new
    array.each { |float_hour| hash_hours[float_hours_to_string(float_hour)] = float_hour}
    hash_hours
  end
  
  def popup_whole_day_information(class_name, value, colspan, checking, leave_start)
    html = ""
    unless class_name.nil?
      html += "<td class='#{class_name}' colspan='#{colspan}'>"
      html +=   value 
      html +=   "<div class='infos'>"
      if class_name == "leave"
        html += leave_information(checking, class_name, leave_start)
      elsif class_name == "absent" 
        html += absence_information(checking, class_name)
      end
      html +=   "</div>"
      html += "</td>"
    end
  end
  
  def popup_hour_modification(class_name, value, schedule_hour, worked_hour, comment)
    html = ""
    value =  value.nil? ? "" : value
    unless class_name.nil?
      html += "<td class='#{class_name}'>"
      html +=   value.gsub(" ", "&nbsp;")
      html +=   "<div class='infos'>"
      html +=   hour_information(worked_hour, schedule_hour, comment, class_name)
      html +=   "</div>"
      html +="</td>"
    else
      html += content_tag :td, value
    end
  end

  def hour_information(schedule_hour,worked_hour,comment,class_name)
    html = ""
    if class_name == "no_hours"
      html +=    no_schedule_hour_information
    else
      html +=   scheduled_hour_information(schedule_hour)
      html +=   overtime_or_delay_information(class_name,worked_hour)
    end
    html +=   hour_comment_information(comment)
  end
  
  def leave_information(checking,class_name,leave_start)
    html = ""
    if class_name == "leave"
      checking.leaves.each do |leave|
       next if leave_start && leave.start_date == checking.date && leave.start_half
       next if leave_start == false && leave.end_date == checking.date && leave.end_half
        html += "<p>"
        html +=    content_tag :span ,"Date debut : "
        value =   leave.start_half ? l(leave.start_date, :format => :long_ordinal) + " dès l'aprés midi " : l(leave.start_date, :format => :long_ordinal)
        html +=    content_tag :span , value
        html +=  "</p>"
        html +=  "<p>"
        html +=    content_tag :span ,"Date de fin : "
        value =   leave.end_half ? l(leave.end_date, :format => :long_ordinal)+ " au matin " : l(leave.end_date, :format => :long_ordinal)
        html +=    content_tag :span , value
        html +=  "</p>"
      end 
    html
    end
  end
  
  def overtime_or_delay_information(class_name,worked_hour)
    html = ""
    if class_name && worked_hour
      if class_name == "overtime"
        html +=  modification_hour_information(worked_hour,"Temps en plus")
      elsif class_name == "delay"
        html +=  modification_hour_information(worked_hour,"Temps de retard")
      end
    end
  end
  
  def scheduled_hour_information(schedule_hour)
    content_tag :p do
      content_tag(:span, 'Heures de service', :class => :label) + ' : ' +
      content_tag(:span, float_hours_to_string(schedule_hour), :class => :value)
    end
  end
  
  def hour_comment_information(comment)
    content_tag :p do
      content_tag(:span, 'Motif', :class => :label) + ' : ' +
      content_tag(:span, comment, :class => :value)
    end
  end
  
  def modification_hour_information(worked_hour,title)
    content_tag :p do
      content_tag(:span, title, :class => :label) + ' : ' +
      content_tag(:span, float_hours_to_string(worked_hour), :class => :value)
    end
  end
  
  def no_schedule_hour_information
    content_tag :p do
      content_tag(:span, "Heures réalisées hors horaires")
    end
  end
  
  def absence_information(checking, class_name)
    if class_name == "absent"
      hour_comment_information(checking.absence_comment)
    end
  end
  
  def display_as_checking_warning(as_employee)
    return unless as_employee
    
    content_tag :div, :class => :alarm do
      "Vous effectuez actuellement le pointage en tant que #{strong(as_employee.fullname)} " +
      link_to("Revenir à mes employés directs", checkings_path(:date => @date), 'data-icon' => :cancel_as_employee)
    end
  end
  
  def display_no_worked_warning(checking)
    return if checking.scheduled_works_whole_day?
    class_message = "warning"
    warning =  "Attention, aucun horaire de service n'a été défini "
    if !checking.scheduled_works_whole_day? && !checking.scheduled_works_today?
      warning += content_tag(:strong, "pour la journée entière")
    elsif !checking.scheduled_works_morning? && checking.scheduled_works_afternoon?
      warning += content_tag(:strong, "pour la matinée")
    elsif !checking.scheduled_works_afternoon? && checking.scheduled_works_morning?
      warning += content_tag(:strong, "pour l'aprés midi")
    end
    warning_box(warning, class_message)
  end
  
  def display_leave_warning(checking)
    return unless checking.is_leave_today?
    class_message = "warning"
    warning = "Attention, vous ne pouvez faire de saisie "
    if checking.is_whole_day_leave?
      warning += content_tag(:strong,"pour la journée entière")
    elsif checking.is_morning_leave?
      warning += content_tag(:strong,"pour la matinée")
    elsif checking.is_afternoon_leave?
      warning += content_tag(:strong,"pour l'aprés midi")
    end
    warning += " car cet employé est en congé"
    warning_box(warning, class_message)
  end
  
  def warning_box(warning, class_message)
    if warning
      content_tag :div, :class => :warning_message do
        content_tag :span, warning, :class => class_message
      end
    else
      ""
    end
  end
  
  def morning_start_class_name(checking)
    if !checking.scheduled_works_morning?
      "no_hours"
    elsif checking.morning_start_is_overtime?
       "overtime"
    elsif checking.morning_start_delay?
       "delay"
    end
  end
  
  def morning_end_class_name(checking)
    if !checking.scheduled_works_morning?
      "no_hours"
    elsif checking.morning_end_is_overtime?
      "overtime"
    elsif checking.morning_end_delay?
      "delay"
    end
  end
  
  def afternoon_start_class_name(checking)
    if !checking.scheduled_works_afternoon?
      "no_hours"
    elsif checking.afternoon_start_is_overtime?
      "overtime"
    elsif checking.afternoon_start_delay?
      "delay"
    end
  end
  
  def afternoon_end_class_name(checking)
    if !checking.scheduled_works_afternoon?
      "no_hours"
    elsif checking.afternoon_end_is_overtime?
      "overtime"
    elsif checking.afternoon_end_delay?
      "delay"
    end
  end
  
  def no_worked_class_name_td(checking)
    if checking.is_leave_today?
      "leave"
    elsif checking.is_absence_today?
      "absent"
    end
  end
  
  def no_worked_value_td(checking)
    if checking.is_leave_today?
      "Congé"
    elsif checking.is_absence_today?
      "Absent"
    end
  end
  
end
