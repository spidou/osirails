module RolesHelper
  
  # to get a preview  of the string
  def preview(string,length)
    return "Pas de description disponible" if string.nil?
    string.length>length ? string[0,length] +" (...)" : string 
  end
  
  def contextual_search_for_role
    contextual_search("Role", { :users => ["username"] })
  end
  
end
