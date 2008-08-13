module PasswordPoliciesHelper
  
  def display_radio(value)
    radio_button_tag( 'level', value, ConfigurationManager.admin_password_policy["actual"] == value )
  end 
  
  def display_text_field
    text_field_tag( "pattern", ConfigurationManager.admin_user_pattern, :size => 50 )
  end
  
  def display_validity_date
    text_field_tag( "validity", ConfigurationManager.admin_password_validity, :size => 4 )
  end

end
