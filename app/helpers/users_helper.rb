module UsersHelper
#  def contextual_search_for_user
#    contextual_search("User", ["*", "roles.name"])
#  end
  
  def query_td_content_for_username_in_user
    link_to(@query_object.username, user_path(@query_object))
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
end
