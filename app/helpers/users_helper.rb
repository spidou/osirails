module UsersHelper
#  def contextual_search_for_user
#    contextual_search("User", ["*", "roles.name"])
#  end
  
  def query_td_content_for_actions_in_user_index
    "#{user_link(@query_object, :link_text => "")} #{edit_user_link(@query_object, :link_text => "")} #{delete_user_link(@query_object, :link_text => "")}"
  end
  
  def query_td_content_for_last_connection_in_user_index
    if @query_object.last_connection
      @query_object.last_connection.humanize
    else
      'Jamais' #:never_conected
    end
  end
end
