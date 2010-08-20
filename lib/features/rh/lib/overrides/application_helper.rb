require_dependency 'app/helpers/application_helper'

module ApplicationHelper
  def display_welcome_message
    "#{t 'welcome'}, #{current_user.employee_name}"
  end
end
