require_dependency 'app/helpers/application_helper'

module ApplicationHelper
  def display_welcome_message
    "Bienvenue, #{current_user.employee_name}"
  end
end
