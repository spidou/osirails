module SocietyIdentityConfigurationHelper
  
  def display_markup(name, value)
    value ||= ""
      if params[:action] == 'edit'
        text_field_tag name, value
      else
        "#{value}"
      end
  end
  
end
