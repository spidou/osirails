module PasswordPoliciesHelper
  
  def display_radio_for_level(value)
    radio_button_tag( 'level', value, ConfigurationManager.admin_actual_password_policy == value ) 
  end 
  
  def display_text_field_for_pattern
    text_field_tag( "pattern", ConfigurationManager.admin_user_pattern, :size => 30 )
  end
  
  def display_text_field_for_validity_date
    text_field_tag( "validity", ConfigurationManager.admin_password_validity, :size => 3 )
  end

end
