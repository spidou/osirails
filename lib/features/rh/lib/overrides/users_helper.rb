require_dependency 'app/helpers/users_helper'

module UsersHelper
  # Override to handle user is enabled or not
  # in more user friendly way for the group display
  #
  
  def query_group_td_content_in_user_index(group_by)
    group_enabled = group_by.detect{ |h| h[:attribute] == 'enabled' }
    if group_enabled
      group_enabled[:value] == true ? 'Actifs' : 'Inactifs'
    end
  end
end
