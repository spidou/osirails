module SocietyIdentityConfigurationHelper
  
  def display_markup(name, value)
    value ||= ""
    if is_form_view?
      text_field_tag name, value 
    else
      "#{strong(value)}"
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
  
  def choosen_theme(name, value)
    path = "public/themes"
    disabled = (params[:action] != 'edit' ? "disabled " : "")
    
    html = ""
    html << "<select #{disabled}id='#{name}' name='#{name}'>\n"
    Dir.open(path).each do |theme|
      selected = (theme == value ? "selected='selected' " : "" )
      html << "<option #{selected}value='#{theme}'>#{theme}</option>\n" unless theme.start_with?(".")
    end
    html << "</select>\n"
    html
  end
  
  def display_time_zone(name, value)
    disabled = is_form_view? ? "" : "disabled='disabled' "
    html = ""
    html << "<select #{disabled}id='#{name}' name='#{name}'>\n"
    html << time_zone_options_for_select(value)
    html << "</select>\n"
  end

	# This method permit to test permission for edit_button (overide dynamic method because there's not model)
  def edit_society_identity_configuration_link(text="")
    if controller.can_edit?(current_user)
      link_to( image_tag("/images/edit_16x16.png", :alt => "Modifier", :title => "Modifier") + " #{text}", edit_society_identity_configuration_path )
    end
  end
end
