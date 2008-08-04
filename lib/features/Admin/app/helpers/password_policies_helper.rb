module PasswordPoliciesHelper
  
  def display_radio(value)
    if ConfigurationManager.admin_password_policy["actual"]==value
      return  radio_button_tag( 'level', value ,true)
    else
      return  radio_button_tag( 'level', value ,false)
    end
  end 
  
  def display_text_field
    value = ConfigurationManager.admin_user_pattern
    return text_field_tag( "pattern", value,  :size => 50)
  end
  
  def display_validity_date
    value = ConfigurationManager.admin_password_validity
    return text_field_tag( "validity", value,  :size =>4)
  end

end
