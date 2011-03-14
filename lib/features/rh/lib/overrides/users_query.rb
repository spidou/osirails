module UsersQuery
  
  # Override to handle user is enabled or not
  # in more user friendly way for the group display
  #
  def query_group_td_content_in_user_index(group_by)
    group_enabled = group_by.detect{ |h| h[:attribute] == 'enabled' }
    if group_enabled
      content_tag(:span, :class => 'not-collapsed', :onclick => "toggleGroup(this);") do
        I18n.t("view.user.#{ group_enabled[:value] == true ? 'enabled' : 'disabled' }_users")
      end
    end
  end
  
end
