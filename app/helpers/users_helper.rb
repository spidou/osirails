module UsersHelper
  def contextual_search_for_user
    contextual_search("User", { :roles => ["name"] })
  end
end
