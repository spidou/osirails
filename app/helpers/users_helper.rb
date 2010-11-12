module UsersHelper
#  def contextual_search_for_user
#    contextual_search("User", ["*", "roles.name"])
#  end
  
  def query_td_content_for_actions_in_user
    "#{user_link(@query_object, :link_text => "")} #{edit_user_link(@query_object, :link_text => "")} #{delete_user_link(@query_object, :link_text => "")}"
  end
  
  def query_td_content_for_last_connection_in_user
    if @query_object.last_connection
      @query_object.last_connection.humanize
    else
      'Jamais' #:never_conected
    end
  end
  
  def query_td_content_for_roles_name_in_user
    @query_object.roles.collect(&:name).join(", ")
  end
  
  def query_th_content_for_employee_fullname_in_user(column, order)
    I18n.t("integrated_search.attributes.user.#{column}") # column should be 'employee.fullname'
  end
end
