module SocietyIdentityConfigurationHelper
  
  def display_markup(name, value)
    value ||= ""
      if params[:action] == 'edit'
        text_field_tag name, value
      else
        "#{value}"
      end
  end
  
  def working_day(value)
    html = ''
    date = Date::today.beginning_of_week
    7.times do |i|
      html += date.strftime("%A") + "<input name=\"admin_society_identity_configuration_working_day[]\" type=\"checkbox\" value=#{i} "
      html += " checked" if value.include?(i.to_s)
      html += " disabled" unless params[:action] == 'edit'
      html += ">"
      date += 1.day
    end
    html
  end
end
